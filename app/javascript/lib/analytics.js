// Google Analytics 4 events, sent through the gtag() defined by the Google Tag
// Manager snippet in the public layout (container GTM-TWRKT9LB → G-7QPZLFHJC8).
//
// Everything here hangs off `document`, which survives Turbo page swaps, so the
// listeners are attached exactly once. When gtag is missing (admin layout, ad
// blockers) every call is a no-op.
//
// GA4 enhanced measurement already records outbound links, file downloads,
// form_start/form_submit, site search and 90% scroll, so none of those are
// duplicated here. Never send personal data (names, emails, phone numbers
// typed into forms): it is against Google Analytics policy.
//
// Events
//   page_view        not sent here: the tag sends the first one, and GA4
//                    enhanced measurement ("page changes based on browser
//                    history events", on in this property) sends one for every
//                    Turbo visit and back/forward. Sending our own as well
//                    doubled every page view. If that setting is ever turned
//                    off, Turbo navigations stop being counted.
//   cta_click        button-styled links: text, destination, page section
//   contact_click    tel:, mailto: and map links (method: phone | email | map)
//   select_item      product links, with the item and the list it was chosen from
//   filter_products  catalogue category chips
//   faq_open         an FAQ answer expanded
//   video_open       the plant film modal
//   theme_change     light/dark toggle
//   quote_download   a valid "Get your quote" submission (the PDF is a download)
//   scroll_depth     25 / 50 / 75 % of a page
//   …plus server-confirmed events rendered into the page by
//   shared/_analytics_events (generate_lead, view_item, quote_error, …).

const SCROLL_MARKS = [25, 50, 75]

let scrollMarksSent = new Set()

export function track(name, params = {}) {
  if (typeof window.gtag !== "function") return
  window.gtag("event", name, params)
}

// Events the server queued for this page (see AnalyticsEvents). The element is
// removed once read so a Turbo cache restore of this page can't replay them.
function flushServerEvents() {
  const element = document.getElementById("analytics-events")
  if (!element) return

  let events = []
  try {
    events = JSON.parse(element.textContent)
  } catch {
    events = []
  }
  element.remove()
  events.forEach(({ name, params }) => track(name, params || {}))
}

// The section a click came from, named the way the scroll readout names it
// (scroll_instrument_controller#collectSections): an explicit
// data-readout-label, else the section's kicker without its "03 / " index,
// else its heading. Outside <main> it is the page chrome.
function sectionOf(element) {
  if (element.closest(".drawer")) return "Mobile menu"
  if (element.closest("header")) return "Header"
  if (element.closest("footer")) return "Footer"

  const section = element.closest("main section")
  if (!section) return "Page"
  if (section.dataset.readoutLabel) return section.dataset.readoutLabel

  const kicker = section.querySelector(".kicker")?.textContent.trim()
  if (kicker) return kicker.replace(/^\d+\s*\/\s*/, "")
  return section.querySelector("h1, h2")?.textContent.replace(/\s+/g, " ").trim() || "Page"
}

function linkText(element) {
  return (element.getAttribute("aria-label") || element.textContent || "").replace(/\s+/g, " ").trim().slice(0, 100)
}

function contactMethod(link) {
  const href = link.getAttribute("href") || ""
  if (href.startsWith("tel:")) return "phone"
  if (href.startsWith("mailto:")) return "email"
  if (/maps\.google\.|google\.[a-z.]+\/maps|goo\.gl\/maps|maps\.app\.goo\.gl/.test(href)) return "map"
  return null
}

// /products/<slug> (not the catalogue itself, not query-only links).
function productSlug(link) {
  const url = new URL(link.href, window.location.href)
  if (url.origin !== window.location.origin) return null
  const match = url.pathname.match(/^\/products\/([^/]+)\/?$/)
  return match ? match[1] : null
}

function handleClick(event) {
  const target = event.target instanceof Element ? event.target : null
  if (!target) return

  // Declarative events: data-analytics-event="name" data-analytics-params='{…}'.
  const declared = target.closest("[data-analytics-event]")
  if (declared) {
    let params = {}
    try {
      params = JSON.parse(declared.dataset.analyticsParams || "{}")
    } catch {
      params = {}
    }
    track(declared.dataset.analyticsEvent, { section: sectionOf(declared), ...params })
    return
  }

  if (target.closest("[data-action~='click->site-nav#toggleTheme']")) {
    // The theme controller runs first (it is bound on the button itself), so
    // the class already reflects the new choice.
    track("theme_change", { theme: document.documentElement.classList.contains("dark") ? "dark" : "light" })
    return
  }

  const chip = target.closest("[data-action~='click->catalog#select']")
  if (chip) {
    track("filter_products", { filter: chip.dataset.filter || "all" })
    return
  }

  const videoTrigger = target.closest("[data-action~='click->video-modal#open']")
  if (videoTrigger) {
    track("video_open", { video_title: linkText(videoTrigger), section: sectionOf(videoTrigger) })
    return
  }

  const faqTrigger = target.closest("[data-analytics-faq] [data-action~='click->accordion#toggle']")
  if (faqTrigger) {
    // Only openings count; the accordion has already flipped aria-expanded.
    if (faqTrigger.getAttribute("aria-expanded") === "true") {
      track("faq_open", { question: linkText(faqTrigger), section: sectionOf(faqTrigger) })
    }
    return
  }

  const link = target.closest("a[href]")
  if (!link) return

  const method = contactMethod(link)
  if (method) {
    track("contact_click", { method, section: sectionOf(link) })
    return
  }

  const slug = productSlug(link)
  if (slug) {
    const card = link.closest("[data-analytics-item-name]")
    track("select_item", {
      item_list_name: sectionOf(link),
      items: [{
        item_id: slug,
        item_name: card?.dataset.analyticsItemName || linkText(link),
        item_category: card?.dataset.analyticsItemCategory
      }]
    })
    return
  }

  if (link.matches(".btn-primary, .btn-dark, .btn-outline, .link-arrow")) {
    const url = new URL(link.href, window.location.href)
    track("cta_click", {
      link_text: linkText(link),
      link_url: url.origin === window.location.origin ? url.pathname + url.search + url.hash : url.href,
      section: sectionOf(link)
    })
  }
}

// "Get your quote" answers with a PDF download, so the page never reloads and
// this submit is the last thing the browser sees. Invalid forms are stopped by
// the quote controller first (defaultPrevented); server-side failures redirect
// back and arrive as a quote_error event.
function handleSubmit(event) {
  const form = event.target
  if (!(form instanceof HTMLFormElement) || event.defaultPrevented) return
  if (!form.matches("[data-controller~='quote']")) return

  const product = form.querySelector("[name='quote[product_id]']")
  const size = form.querySelector("[name='quote[size]']")?.value
  const quantity = parseFloat(form.querySelector("[name='quote[quantity]']")?.value)
  const productName = product?.selectedOptions[0]?.textContent.trim()

  track("quote_download", {
    product: productName,
    size,
    quantity_mt: Number.isFinite(quantity) ? quantity : undefined,
    items: [{ item_id: product?.selectedOptions[0]?.dataset.slug || product?.value, item_name: productName, item_variant: size }]
  })
}

function handleScroll() {
  const scrollable = document.documentElement.scrollHeight - window.innerHeight
  if (scrollable <= 0) return

  const percent = (window.scrollY / scrollable) * 100
  SCROLL_MARKS.forEach((mark) => {
    if (percent >= mark && !scrollMarksSent.has(mark)) {
      scrollMarksSent.add(mark)
      track("scroll_depth", { percent_scrolled: mark })
    }
  })
}

let scrollQueued = false
function onScroll() {
  if (scrollQueued) return
  scrollQueued = true
  requestAnimationFrame(() => {
    scrollQueued = false
    handleScroll()
  })
}

document.addEventListener("turbo:load", () => {
  scrollMarksSent = new Set()
  flushServerEvents()
})
document.addEventListener("click", handleClick)
document.addEventListener("submit", handleSubmit)
window.addEventListener("scroll", onScroll, { passive: true })

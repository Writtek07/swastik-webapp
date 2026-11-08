import { Controller } from "@hotwired/stimulus"

// Scroll instrumentation: the progress rail, the section readout, parallax
// layers and the stat gauges. The marquee deliberately isn't wired in: it runs
// at a constant pace in CSS, independent of vertical scrolling.
//
// All of it is derived from one scroll position, so it is computed in a single
// rAF loop rather than in a scroll handler. The loop only runs while the page is
// actually moving — it parks itself once the position settles, which keeps the
// main thread free on a page this long.
export default class extends Controller {
  static targets = ["bar", "readoutIndex", "readoutLabel", "readoutThumb"]

  connect() {
    this.reducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches

    this.lastY = window.scrollY
    this.velocity = 0
    this.running = false
    this.sections = []

    this.collectSections()
    this.measure()

    this.onScroll = this.handleScroll.bind(this)
    this.onResize = this.measure.bind(this)

    window.addEventListener("scroll", this.onScroll, { passive: true })
    window.addEventListener("resize", this.onResize)

    this.render()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    window.removeEventListener("resize", this.onResize)
    if (this.frameId) cancelAnimationFrame(this.frameId)
    clearTimeout(this.hideReadoutId)
  }

  // Sections are the top-level blocks of the page, used for the readout. The
  // label prefers an explicit `data-readout-label`, then the section's own
  // kicker (which already reads "03 / Capability" — the leading index is
  // stripped because the readout supplies its own), and finally the heading.
  // Deriving from the section's own copy keeps the readout from drifting out of
  // step with the content. Decorative bands opt out with `data-readout-skip`.
  collectSections() {
    this.sections = Array.from(document.querySelectorAll("main > section, main > div > section"))
      .filter((el) => !el.hasAttribute("data-readout-skip"))
      .map((el) => {
        const kicker = el.querySelector(".kicker")?.textContent.trim()
        const heading = el.querySelector("h1, h2")?.textContent.trim()
        const label = el.dataset.readoutLabel
          || kicker?.replace(/^\d+\s*\/\s*/, "")
          || heading?.replace(/\s+/g, " ")
          || ""
        return { el, label }
      })
      .filter((section) => section.label)
  }

  measure() {
    this.docHeight = Math.max(document.documentElement.scrollHeight - window.innerHeight, 1)
    this.parallaxLayers = Array.from(document.querySelectorAll(".parallax")).map((el) => {
      // The offset is clamped to the layer's own section so a layer can never
      // drift more than a fraction of the section it belongs to. Without this
      // the offset grows without limit as the document scrolls, which is only
      // invisible today because every layer happens to sit inside an
      // `overflow-hidden` section.
      const section = el.closest("section") || el.parentElement
      return {
        el,
        speed: Number(el.dataset.parallaxSpeed || 0.08),
        top: el.getBoundingClientRect().top + window.scrollY,
        limit: Math.max((section?.offsetHeight || window.innerHeight) * 0.12, 24)
      }
    })
  }

  handleScroll() {
    if (this.running) return
    this.running = true
    this.frameId = requestAnimationFrame(this.tick)
  }

  tick = () => {
    const y = window.scrollY
    // Smoothed so trackpad micro-deltas don't keep the loop alive.
    this.velocity = this.velocity * 0.75 + (y - this.lastY) * 0.25
    this.lastY = y

    this.render()

    // Park the loop once the page has settled and the velocity has decayed.
    if (Math.abs(this.velocity) < 0.05) {
      this.velocity = 0
      this.running = false
      this.render()
      return
    }

    this.frameId = requestAnimationFrame(this.tick)
  }

  render() {
    const y = window.scrollY
    const progress = Math.min(Math.max(y / this.docHeight, 0), 1)

    this.renderRail(progress)
    this.renderReadout(y)
    this.renderParallax(y)
    this.renderGauges()
  }

  renderRail(progress) {
    if (!this.hasBarTarget) return
    this.barTarget.style.setProperty("--progress", progress.toFixed(4))
  }

  renderReadout(y) {
    if (!this.hasReadoutIndexTarget || !this.sections.length) return

    // The active section is the last one whose top has passed the viewport
    // midpoint, which matches where the eye actually is.
    const midpoint = y + window.innerHeight * 0.4
    let index = 0
    this.sections.forEach((section, i) => {
      if (section.el.offsetTop <= midpoint) index = i
    })

    const total = this.sections.length
    const current = this.sections[index]

    this.readoutIndexTarget.textContent =
      `${String(index + 1).padStart(2, "0")}·${String(total).padStart(2, "0")}`
    this.readoutLabelTarget.textContent = current.label
    this.readoutThumbTarget?.style.setProperty("--progress", (y / this.docHeight).toFixed(4))

    // Reveal only while the page is genuinely moving, and hide once it settles.
    // Measured velocity: ~5 for a slow reading scroll, ~11 for a mouse wheel,
    // ~17 for a trackpad, ~96 for PageDown. The threshold sits just above the
    // reading case so the panel appears for every deliberate scroll input but
    // stays out of the way while the user is reading. The hide is debounced so a
    // velocity hovering around the threshold cannot make the panel flicker.
    const readout = this.readoutIndexTarget.closest(".section-readout")
    if (readout) {
      if (Math.abs(this.velocity) > 10) {
        clearTimeout(this.hideReadoutId)
        this.hideReadoutId = null
        readout.classList.add("is-visible")
      } else if (!this.hideReadoutId) {
        this.hideReadoutId = setTimeout(() => {
          readout.classList.remove("is-visible")
          this.hideReadoutId = null
        }, 180)
      }
    }
  }

  renderParallax(y) {
    if (this.reducedMotion) return

    this.parallaxLayers.forEach((layer) => {
      // Offset is measured from the viewport centre so layers are neutral when
      // they are in the middle of the screen and drift as they pass through.
      const viewportCentre = y + window.innerHeight / 2
      const raw = (viewportCentre - layer.top) * layer.speed
      const offset = Math.max(Math.min(raw, layer.limit), -layer.limit)
      layer.el.style.setProperty("--parallax", `${offset.toFixed(2)}px`)
    })
  }

  // Gauges fill as their stat block travels up the viewport, so the number and
  // the hairline finish together.
  renderGauges() {
    document.querySelectorAll(".stat-gauge").forEach((gauge) => {
      const rect = gauge.getBoundingClientRect()
      const fill = Math.min(Math.max((window.innerHeight - rect.top) / (window.innerHeight * 0.7), 0), 1)
      gauge.style.setProperty("--gauge", fill.toFixed(4))
    })
  }
}

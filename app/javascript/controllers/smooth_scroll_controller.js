import { Controller } from "@hotwired/stimulus"
import Lenis from "lenis"

// Smooth scrolling, owned by Lenis.
//
// Lenis is a singleton concern: one instance drives the whole document, so this
// controller is mounted once on <body> and exposes itself on `window` for the
// other controllers that need to read scroll position or request a scroll.
//
// Two things make this safe inside a Turbo app:
//   * `disconnect()` destroys the instance and cancels the rAF loop, so a
//     cached page never leaves a second Lenis running behind the new one.
//   * `turbo:before-cache` fires before the snapshot is taken, which is the
//     last moment we can stop the loop without the frozen frame showing a
//     mid-scroll transform.
export default class extends Controller {
  static values = {
    // Higher = heavier. 1.1 keeps the industrial pages feeling weighted without
    // the lag that makes long specification tables feel unresponsive.
    lerp: { type: Number, default: 1.1 },
    // Anchor links are routed through Lenis so they ease instead of jumping.
    anchorSelector: { type: String, default: 'a[href^="#"]' }
  }

  connect() {
    // Reduced motion means no smooth scrolling at all — native scrolling is
    // left completely untouched, including the CSS `scroll-behavior` fallback.
    if (this.prefersReducedMotion) return

    this.lenis = new Lenis({
      lerp: this.lerpValue,
      wheelMultiplier: 1,
      touchMultiplier: 1.6,
      // Lenis must not smooth the horizontal axis; the catalogue filter row and
      // the slider both scroll sideways and would feel broken.
      syncTouch: false
    })

    this.onAnchorClick = this.handleAnchorClick.bind(this)
    this.onBeforeCache = this.destroyLenis.bind(this)

    // Capture phase: Turbo Drive also listens for anchor clicks on `document`
    // and would start its own scroll before our bubble-phase handler could
    // preventDefault, leaving two scroll animations fighting each other.
    document.addEventListener("click", this.onAnchorClick, true)
    document.addEventListener("turbo:before-cache", this.onBeforeCache)

    this.rafId = requestAnimationFrame(this.raf)
    window.__lenis = this.lenis

    // The first-visit preloader owns the screen until it lifts: keep Lenis
    // stopped so wheel and touch input can't scroll the page behind it, then
    // start from the very top once it signals it is done.
    if (document.documentElement.classList.contains("is-preloading")) {
      this.lenis.stop()
      this.onPreloaderDone = () => {
        this.lenis?.scrollTo(0, { immediate: true, force: true })
        this.lenis?.start()
      }
      window.addEventListener("preloader:done", this.onPreloaderDone, { once: true })
    }
  }

  disconnect() {
    document.removeEventListener("click", this.onAnchorClick, true)
    document.removeEventListener("turbo:before-cache", this.onBeforeCache)
    if (this.onPreloaderDone) window.removeEventListener("preloader:done", this.onPreloaderDone)
    this.destroyLenis()
  }

  destroyLenis() {
    if (this.rafId) cancelAnimationFrame(this.rafId)
    this.rafId = null
    this.lenis?.destroy()
    this.lenis = null
    if (window.__lenis) delete window.__lenis
  }

  raf = (time) => {
    this.lenis?.raf(time)
    this.rafId = requestAnimationFrame(this.raf)
  }

  // Anchor links are intercepted so they ease through Lenis. The offset leaves
  // room for the sticky header, matching the `scroll-mt-*` utilities already on
  // the target sections.
  handleAnchorClick(event) {
    const link = event.target.closest?.(this.anchorSelectorValue)
    if (!link) return

    const hash = link.getAttribute("href")
    if (!hash || hash === "#") return

    const target = document.querySelector(hash)
    if (!target) return

    event.preventDefault()
    this.lenis?.scrollTo(target, { offset: -96, duration: 1.1 })

    // Keep the URL and the focus ring in step with the visual scroll, otherwise
    // keyboard users are left at the top of the document.
    history.pushState(null, "", hash)
    target.setAttribute("tabindex", "-1")
    target.focus({ preventScroll: true })
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }
}

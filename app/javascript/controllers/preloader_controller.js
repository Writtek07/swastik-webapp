import { Controller } from "@hotwired/stimulus"

// First-visit intro screen.
//
// The <head> script decides whether the intro plays (once per session, never
// under reduced motion) by putting `is-preloading` on <html>. While that class
// is present, CSS locks native scrolling and the smooth-scroll controller holds
// Lenis stopped. This controller then:
//
//   1. eases a 0–100 counter towards real load progress (fonts, the window
//      `load` event) but never faster than MIN_DURATION, so the intro always
//      has time to play;
//   2. lifts the panel away, and at that moment drops `is-preloading` and
//      fires `preloader:done` on window, which restarts Lenis and lets the
//      reveal controller start the hero's entrance animations underneath.
const MIN_DURATION = 2200
// A slow third-party image shouldn't hold the intro hostage: past this point
// the page is treated as loaded and the curtain lifts regardless.
const MAX_WAIT = 5000
const EXIT_DURATION = 1300
const STORAGE_KEY = "swastik:intro-seen"
const STATUSES = [
  [0, "Heating the furnace"],
  [35, "Rolling sections"],
  [70, "Testing grades"],
  [96, "Ready for dispatch"]
]

export default class extends Controller {
  static targets = ["count", "bar", "status", "panel"]

  connect() {
    if (!document.documentElement.classList.contains("is-preloading")) {
      this.element.remove()
      return
    }

    // The controller is alive, so the <head> failsafe (there in case the JS
    // bundle never runs) is no longer needed; MAX_WAIT covers slow loads.
    clearTimeout(window.__introFailsafe)

    this.startedAt = performance.now()
    this.shown = 0
    this.loaded = { fonts: false, window: document.readyState === "complete" }

    document.fonts?.ready.then(() => (this.loaded.fonts = true))
    if (!document.fonts) this.loaded.fonts = true
    if (!this.loaded.window) {
      this.onLoad = () => (this.loaded.window = true)
      window.addEventListener("load", this.onLoad, { once: true })
    }

    this.frame = requestAnimationFrame(this.tick)
  }

  disconnect() {
    cancelAnimationFrame(this.frame)
    clearTimeout(this.exitTimer)
    if (this.onLoad) window.removeEventListener("load", this.onLoad)
  }

  tick = (now) => {
    // rAF timestamps mark the start of the frame, which can precede the
    // performance.now() taken in connect(); clamp so progress never dips below 0.
    const elapsed = Math.max(now - this.startedAt, 0)
    const timeProgress = Math.min(elapsed / MIN_DURATION, 1) * 100
    // Until everything has loaded, creep asymptotically towards 90 so the
    // counter keeps moving on a slow connection without claiming completion.
    const ready = (this.loaded.fonts && this.loaded.window) || elapsed > MAX_WAIT
    const loadProgress = ready ? 100 : 90 * (1 - Math.exp(-elapsed / 1800))
    const goal = Math.min(timeProgress, loadProgress)

    this.shown += (goal - this.shown) * 0.12
    if (goal === 100 && this.shown > 99.4) this.shown = 100
    this.render(this.shown)

    if (this.shown >= 100) {
      this.finish()
    } else {
      this.frame = requestAnimationFrame(this.tick)
    }
  }

  render(value) {
    const rounded = Math.floor(value)
    this.countTarget.textContent = String(rounded).padStart(3, "0")
    this.barTarget.style.transform = `scaleX(${value / 100})`

    const status = STATUSES.filter(([at]) => rounded >= at).pop()[1]
    if (this.statusTarget.textContent !== status) this.statusTarget.textContent = status
  }

  finish() {
    try { sessionStorage.setItem(STORAGE_KEY, "1") } catch {}

    this.element.classList.add("is-leaving")
    // Unlock as the curtain starts to lift, so the hero animates in beneath it
    // rather than after it has gone.
    document.documentElement.classList.remove("is-preloading")
    window.dispatchEvent(new CustomEvent("preloader:done"))

    this.exitTimer = setTimeout(() => this.element.remove(), EXIT_DURATION)
  }
}

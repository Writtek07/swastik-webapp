import { Controller } from "@hotwired/stimulus"

// Reveals elements as they scroll into view and animates any counters inside
// them. One observer per page keeps the cost flat regardless of section count.
export default class extends Controller {
  static targets = ["item", "counter"]

  connect() {
    if (this.prefersReducedMotion) {
      this.itemTargets.forEach((el) => el.classList.add("is-visible"))
      this.counterTargets.forEach((el) => this.renderCounter(el, Number(el.dataset.counter)))
      return
    }

    this.observer = new IntersectionObserver(
      (entries) => {
        entries.forEach((entry) => {
          if (!entry.isIntersecting) return
          entry.target.classList.add("is-visible")
          this.animateCounters(entry.target)
          this.observer.unobserve(entry.target)
        })
      },
      { threshold: 0.15, rootMargin: "0px 0px -60px 0px" }
    )

    // Behind the first-visit preloader the hero is already "in view", so its
    // entrance would finish unseen. Start observing when the curtain lifts.
    if (document.documentElement.classList.contains("is-preloading")) {
      this.onPreloaderDone = () => this.observeItems()
      window.addEventListener("preloader:done", this.onPreloaderDone, { once: true })
    } else {
      this.observeItems()
    }
  }

  disconnect() {
    this.observer?.disconnect()
    if (this.onPreloaderDone) window.removeEventListener("preloader:done", this.onPreloaderDone)
  }

  observeItems() {
    this.itemTargets.forEach((el) => this.observer.observe(el))
  }

  get prefersReducedMotion() {
    return window.matchMedia("(prefers-reduced-motion: reduce)").matches
  }

  animateCounters(root) {
    root.querySelectorAll("[data-counter]").forEach((el) => {
      if (el.dataset.counted === "true") return
      el.dataset.counted = "true"
      this.countUp(el, Number(el.dataset.counter))
    })
  }

  countUp(el, target) {
    const duration = 1100
    const start = performance.now()

    const tick = (now) => {
      const progress = Math.min((now - start) / duration, 1)
      // Ease-out cubic so the number decelerates into its final value.
      const eased = 1 - Math.pow(1 - progress, 3)
      this.renderCounter(el, Math.round(eased * target))
      if (progress < 1) requestAnimationFrame(tick)
    }

    requestAnimationFrame(tick)
  }

  renderCounter(el, value) {
    el.textContent = `${value}${el.dataset.suffix || ""}`
  }
}

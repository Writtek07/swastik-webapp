import { Controller } from "@hotwired/stimulus"

// Horizontal scroll-snap slider with prev/next controls and a progress bar.
export default class extends Controller {
  static targets = ["track", "prev", "next", "progress"]

  connect() {
    this.onScroll = this.sync.bind(this)
    this.trackTarget.addEventListener("scroll", this.onScroll, { passive: true })
    this.sync()
  }

  disconnect() {
    this.trackTarget.removeEventListener("scroll", this.onScroll)
  }

  next() {
    this.scrollBy(1)
  }

  prev() {
    this.scrollBy(-1)
  }

  scrollBy(direction) {
    const slide = this.trackTarget.querySelector(".slider-slide")
    const step = slide ? slide.offsetWidth + 20 : this.trackTarget.clientWidth * 0.8
    this.trackTarget.scrollBy({ left: step * direction, behavior: "smooth" })
  }

  sync() {
    const { scrollLeft, scrollWidth, clientWidth } = this.trackTarget
    const max = scrollWidth - clientWidth
    const ratio = max <= 0 ? 1 : scrollLeft / max

    if (this.hasProgressTarget) {
      this.progressTarget.style.transform = `scaleX(${Math.max(ratio, 0.06)})`
    }
    if (this.hasPrevTarget) this.prevTarget.disabled = scrollLeft <= 4
    if (this.hasNextTarget) this.nextTarget.disabled = scrollLeft >= max - 4
  }
}

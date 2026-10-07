import { Controller } from "@hotwired/stimulus"

// Hero background video.
//
// The markup ships a CSS fallback layer so the hero looks finished before any
// media exists. When a real file is present the <video> element fires `canplay`
// and we fade the fallback out. If the source is missing or the browser blocks
// autoplay, the fallback simply stays.
export default class extends Controller {
  static targets = ["video", "fallback", "toggle"]
  static values = { src: String }

  connect() {
    this.media = this.hasVideoTarget ? this.videoTarget : null

    if (!this.media || !this.mediaSrc) {
      this.showFallback()
      return
    }

    // Attach the source only when one is configured, so an empty value never
    // makes the browser request the page itself as media.
    if (!this.media.currentSrc) {
      const source = document.createElement("source")
      source.src = this.mediaSrc
      source.type = "video/mp4"
      this.media.append(source)
    }

    this.media.addEventListener("canplay", this.handleCanPlay, { once: true })
    this.media.addEventListener("error", this.showFallback, { once: true })

    // Autoplay is best-effort: a rejected promise is not an error worth surfacing.
    this.media.play?.().catch(() => this.showFallback())
  }

  disconnect() {
    this.media?.removeEventListener("canplay", this.handleCanPlay)
    this.media?.removeEventListener("error", this.showFallback)
  }

  get mediaSrc() {
    return this.hasSrcValue ? this.srcValue : this.media?.currentSrc || this.media?.querySelector("source")?.src
  }

  handleCanPlay = () => {
    this.fallbackTargets.forEach((el) => el.classList.add("opacity-0"))
    this.element.dataset.videoReady = "true"
  }

  showFallback = () => {
    this.element.dataset.videoReady = "false"
    this.fallbackTargets.forEach((el) => el.classList.remove("opacity-0"))
  }

  // Lets visitors pause the loop without leaving the page.
  toggle() {
    if (!this.media) return
    if (this.media.paused) {
      this.media.play().catch(() => {})
    } else {
      this.media.pause()
    }
    this.syncToggle()
  }

  syncToggle() {
    if (!this.hasToggleTarget) return
    const paused = this.media?.paused ?? true
    this.toggleTarget.setAttribute("aria-label", paused ? "Play background video" : "Pause background video")
    this.toggleTarget.dataset.paused = paused ? "true" : "false"
  }
}

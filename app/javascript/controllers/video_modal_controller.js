import { Controller } from "@hotwired/stimulus"

// Lightbox for the company film. Accepts either an embed URL (YouTube/Vimeo) or
// a local video source, so the same modal works before and after real media is
// added to the project.
export default class extends Controller {
  static targets = ["modal", "embed", "fallback"]
  static values = {
    url: String,
    src: String,
    title: { type: String, default: "Company film" }
  }

  open(event) {
    const trigger = event?.currentTarget
    const url = trigger?.dataset.videoModalUrlValue || this.urlValue
    const src = trigger?.dataset.videoModalSrcValue || this.srcValue

    this.modalTarget.classList.remove("hidden")
    this.modalTarget.classList.add("flex")
    document.body.classList.add("overflow-hidden")

    if (url) {
      this.renderEmbed(url)
    } else if (src) {
      this.renderVideo(src)
    } else {
      this.showFallback()
    }
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.modalTarget.classList.remove("flex")
    document.body.classList.remove("overflow-hidden")
    // Clearing the embed stops playback and releases the network connection.
    this.embedTarget.innerHTML = ""
    this.embedTarget.classList.add("hidden")
    this.showFallback()
  }

  closeOnBackdrop(event) {
    if (event.target === this.modalTarget) this.close()
  }

  renderEmbed(url) {
    this.fallbackTarget.classList.add("hidden")
    this.embedTarget.classList.remove("hidden")
    this.embedTarget.innerHTML = `
      <iframe
        class="h-full w-full"
        src="${this.escape(url)}"
        title="${this.escape(this.titleValue)}"
        frameborder="0"
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowfullscreen></iframe>`
  }

  renderVideo(src) {
    this.fallbackTarget.classList.add("hidden")
    this.embedTarget.classList.remove("hidden")
    this.embedTarget.innerHTML = `
      <video class="h-full w-full object-cover" src="${this.escape(src)}" controls autoplay playsinline></video>`
  }

  showFallback() {
    this.fallbackTarget.classList.remove("hidden")
  }

  escape(value) {
    return String(value).replace(/[&<>"']/g, (character) => ({
      "&": "&amp;",
      "<": "&lt;",
      ">": "&gt;",
      '"': "&quot;",
      "'": "&#39;"
    })[character])
  }
}

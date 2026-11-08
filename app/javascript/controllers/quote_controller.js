import { Controller } from "@hotwired/stimulus"

// "Get your quote": fills the size select with the sizes priced for the chosen
// product, and briefly disables the button while the PDF downloads (the
// response is a file, so the page never reloads to reset it).
export default class extends Controller {
  static targets = ["product", "size", "submit", "submitLabel"]
  static values = { sizes: Object }

  connect() {
    this.productChanged()
  }

  productChanged() {
    const sizes = this.sizesValue[this.productTarget.value] || []
    const selected = this.sizeTarget.value

    this.sizeTarget.replaceChildren(
      new Option(sizes.length ? "Select a size" : "Select a product first", ""),
      ...sizes.map((size) => new Option(size, size, false, size === selected))
    )
    this.sizeTarget.disabled = sizes.length === 0
  }

  submit(event) {
    if (!this.element.checkValidity()) {
      event.preventDefault()
      this.element.reportValidity()
      return
    }

    this.submitTarget.disabled = true
    this.submitLabelTarget.textContent = "Preparing PDF…"
    clearTimeout(this.resetTimer)
    this.resetTimer = setTimeout(() => {
      this.submitTarget.disabled = false
      this.submitLabelTarget.textContent = "Download quote"
    }, 2500)
  }

  disconnect() {
    clearTimeout(this.resetTimer)
  }
}

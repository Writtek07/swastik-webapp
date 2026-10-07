import { Controller } from "@hotwired/stimulus"

// Enquiry form: client-side validation feedback plus a submit state so the
// button cannot be double-fired while Rails processes the POST.
export default class extends Controller {
  static targets = ["form", "submit", "submitLabel", "success"]

  submit(event) {
    if (!this.formTarget.checkValidity()) {
      // Let the browser surface its native validation UI.
      event.preventDefault()
      this.formTarget.reportValidity()
      return
    }

    this.setBusy(true)
  }

  setBusy(busy) {
    if (!this.hasSubmitTarget) return
    this.submitTarget.disabled = busy
    if (this.hasSubmitLabelTarget) {
      this.submitLabelTarget.textContent = busy ? "Sending…" : "Send enquiry"
    }
  }

  // Called by Turbo when the form is restored after a validation failure.
  reset() {
    this.setBusy(false)
  }
}

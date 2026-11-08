import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form when a filter control changes, so GET filters
// (date picker, product select) apply without a separate button.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}

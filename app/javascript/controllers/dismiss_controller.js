import { Controller } from "@hotwired/stimulus"

// Removes a flash message from the page.
export default class extends Controller {
  close() {
    this.element.remove()
  }
}

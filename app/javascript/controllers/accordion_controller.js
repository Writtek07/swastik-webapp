import { Controller } from "@hotwired/stimulus"

// Accessible accordion used by the FAQ list and the mobile nav groups.
// The panel animates with grid-template-rows so it works with unknown heights.
export default class extends Controller {
  static targets = ["trigger", "panel"]
  static values = { openFirst: Boolean }

  connect() {
    if (this.openFirstValue && this.triggerTargets.length) {
      this.setOpen(this.triggerTargets[0], true)
    }
  }

  toggle(event) {
    const trigger = event.currentTarget
    const isOpen = trigger.getAttribute("aria-expanded") === "true"
    this.setOpen(trigger, !isOpen)
  }

  setOpen(trigger, open) {
    const panel = this.panelFor(trigger)
    trigger.setAttribute("aria-expanded", String(open))
    if (panel) panel.dataset.open = String(open)
  }

  panelFor(trigger) {
    const index = this.triggerTargets.indexOf(trigger)
    return index === -1 ? null : this.panelTargets[index]
  }
}

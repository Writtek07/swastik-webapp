import { Controller } from "@hotwired/stimulus"

// Primary navigation: desktop mega menu, mobile drawer, scroll state and the
// light/dark theme toggle. Kept in one controller because all four concerns
// share the same header element and lifecycle.
export default class extends Controller {
  static targets = ["group", "trigger", "panel", "drawer", "scrim", "openButton"]
  static values = { themeKey: { type: String, default: "swastik-theme" } }

  connect() {
    this.closeTimer = null
    this.restoreTheme()
    this.onScroll = this.handleScroll.bind(this)
    window.addEventListener("scroll", this.onScroll, { passive: true })
    this.handleScroll()
  }

  disconnect() {
    window.removeEventListener("scroll", this.onScroll)
    clearTimeout(this.closeTimer)
    document.body.classList.remove("overflow-hidden")
  }

  // --- Mega menu -----------------------------------------------------------
  //
  // The panel is a sibling of the trigger's group (it spans the full header
  // width), so the close must be scoped to the whole header rather than to the
  // group. Otherwise moving the pointer from the trigger down into the panel
  // fires mouseleave on the group and the panel closes before it can be clicked.

  openGroup(event) {
    clearTimeout(this.closeTimer)
    // The action sits on the group wrapper, so resolve the panel by group index.
    const index = this.groupTargets.indexOf(event.currentTarget)
    this.showPanel(this.panelTargets[index])
  }

  // Cancels a pending close. Bound to the panel so a pointer that is already
  // inside it keeps it open even if the grace period elapsed.
  keepOpen(event) {
    clearTimeout(this.closeTimer)
    const panel = event?.currentTarget
    if (panel && this.panelTargets.includes(panel) && panel.dataset.open !== "true") {
      this.showPanel(panel)
    }
  }

  // Delayed so the pointer can travel between the trigger and the panel.
  scheduleClose() {
    clearTimeout(this.closeTimer)
    this.closeTimer = setTimeout(() => this.closePanels(), 200)
  }

  // Closes the menu once focus leaves the header, so keyboard users are not
  // left with an open panel behind them.
  handleFocusOut(event) {
    const next = event.relatedTarget
    if (next && this.element.contains(next)) return
    this.closePanels()
  }

  toggleGroup(event) {
    const panel = this.panelFor(event.currentTarget)
    if (panel?.dataset.open === "true") {
      this.closePanels()
    } else {
      this.showPanel(panel)
    }
  }

  showPanel(panel) {
    if (!panel) return
    this.closePanels()
    panel.hidden = false
    // Next frame so the transition runs from the closed state.
    requestAnimationFrame(() => {
      panel.dataset.open = "true"
      this.triggerFor(panel)?.setAttribute("aria-expanded", "true")
    })
  }

  closePanels() {
    this.panelTargets.forEach((panel) => {
      panel.dataset.open = "false"
      this.triggerFor(panel)?.setAttribute("aria-expanded", "false")
      // Wait for the fade before removing from the accessibility tree.
      setTimeout(() => {
        if (panel.dataset.open === "false") panel.hidden = true
      }, 200)
    })
  }

  panelFor(trigger) {
    const index = this.triggerTargets.indexOf(trigger)
    return index === -1 ? null : this.panelTargets[index]
  }

  triggerFor(panel) {
    const index = this.panelTargets.indexOf(panel)
    return index === -1 ? null : this.triggerTargets[index]
  }

  // --- Mobile drawer -------------------------------------------------------

  openDrawer() {
    this.drawerTarget.dataset.open = "true"
    this.drawerTarget.setAttribute("aria-hidden", "false")
    this.scrimTarget.dataset.open = "true"
    this.openButtonTarget.setAttribute("aria-expanded", "true")
    document.body.classList.add("overflow-hidden")
  }

  closeDrawer() {
    this.drawerTarget.dataset.open = "false"
    this.drawerTarget.setAttribute("aria-hidden", "true")
    this.scrimTarget.dataset.open = "false"
    this.openButtonTarget.setAttribute("aria-expanded", "false")
    document.body.classList.remove("overflow-hidden")
  }

  closeAll() {
    this.closePanels()
    this.closeDrawer()
  }

  // --- Header state --------------------------------------------------------

  handleScroll() {
    this.element.dataset.scrolled = window.scrollY > 12 ? "true" : "false"
  }

  // --- Theme ---------------------------------------------------------------

  toggleTheme() {
    const dark = !document.documentElement.classList.contains("dark")
    document.documentElement.classList.toggle("dark", dark)
    try {
      localStorage.setItem(this.themeKeyValue, dark ? "dark" : "light")
    } catch {
      // Storage can be unavailable in private modes; the toggle still works.
    }
  }

  restoreTheme() {
    let saved = null
    try {
      saved = localStorage.getItem(this.themeKeyValue)
    } catch {
      saved = null
    }
    if (saved === "dark") document.documentElement.classList.add("dark")
    if (saved === "light") document.documentElement.classList.remove("dark")
  }
}

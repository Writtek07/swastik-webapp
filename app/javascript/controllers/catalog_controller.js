import { Controller } from "@hotwired/stimulus"

// Product catalogue filtering on /products.
//
// Filtering is client-side so switching families is instant. The URL is updated
// with replaceState so a filtered view stays shareable and survives a refresh.
export default class extends Controller {
  static targets = ["chip", "card", "empty", "count"]
  static values = { param: { type: String, default: "category" } }

  connect() {
    this.apply(this.activeFromUrl(), { updateUrl: false })
  }

  select(event) {
    this.apply(event.currentTarget.dataset.filter, { updateUrl: true })
  }

  activeFromUrl() {
    const params = new URLSearchParams(window.location.search)
    return params.get(this.paramValue) || "all"
  }

  apply(filter, { updateUrl }) {
    let visible = 0

    this.chipTargets.forEach((chip) => {
      const active = chip.dataset.filter === filter
      chip.classList.toggle("is-active", active)
      chip.setAttribute("aria-selected", String(active))
      chip.tabIndex = active ? 0 : -1
    })

    this.cardTargets.forEach((card) => {
      const match = filter === "all" || card.dataset.category === filter
      card.classList.toggle("hidden", !match)
      if (!match) return

      visible += 1
      // Re-trigger the entrance transition on every filter change.
      card.classList.remove("is-entering")
      requestAnimationFrame(() => {
        card.classList.add("is-entering")
        setTimeout(() => card.classList.remove("is-entering"), 420)
      })
    })

    if (this.hasEmptyTarget) this.emptyTarget.classList.toggle("hidden", visible !== 0)
    if (this.hasCountTarget) this.countTarget.textContent = visible

    if (updateUrl) this.syncUrl(filter)
  }

  syncUrl(filter) {
    const url = new URL(window.location.href)
    if (filter === "all") {
      url.searchParams.delete(this.paramValue)
    } else {
      url.searchParams.set(this.paramValue, filter)
    }
    window.history.replaceState({}, "", url)
  }
}

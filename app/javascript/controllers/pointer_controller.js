import { Controller } from "@hotwired/stimulus"

// Pointer-driven reactivity: the blueprint grid highlight, the 3D tilt on
// product plates, and the magnetic lean on buttons.
//
// These three effects share a single `pointermove` listener and a single rAF
// loop. Registering one listener per element would mean dozens of handlers
// firing per frame on the catalogue page, so instead we resolve the element
// under the pointer once and only write the custom properties that element
// actually consumes.
//
// Mounted once on <body>. Everything is inert on touch devices and under
// `prefers-reduced-motion`.
export default class extends Controller {
  static values = {
    // Maximum tilt in degrees. Small on purpose — these are technical drawings,
    // not trading cards.
    tiltMax: { type: Number, default: 7 },
    // How far a magnetic button leans toward the pointer, in pixels.
    magnetStrength: { type: Number, default: 6 }
  }

  connect() {
    if (!this.enabled) return

    this.pointer = { x: 0, y: 0 }
    this.pending = false
    this.activePlate = null
    this.activeMagnet = null
    this.grids = []

    this.onPointerMove = this.handlePointerMove.bind(this)
    this.onPointerLeave = this.reset.bind(this)
    this.measureGrids = this.measureGrids.bind(this)

    window.addEventListener("pointermove", this.onPointerMove, { passive: true })
    document.addEventListener("pointerleave", this.onPointerLeave)
    // Grid rects are viewport-relative, so they are re-read when the page moves
    // rather than inside the rAF loop.
    window.addEventListener("scroll", this.measureGrids, { passive: true })
    window.addEventListener("resize", this.measureGrids)

    this.measureGrids()
  }

  disconnect() {
    window.removeEventListener("pointermove", this.onPointerMove)
    document.removeEventListener("pointerleave", this.onPointerLeave)
    window.removeEventListener("scroll", this.measureGrids)
    window.removeEventListener("resize", this.measureGrids)
    if (this.frameId) cancelAnimationFrame(this.frameId)
  }

  // The blueprint grids are painted *under* the hero's gradient overlays, so
  // hit-testing them with `elementFromPoint` never reaches them. Instead the
  // grids are cached with their viewport rects and matched by geometry, which
  // also keeps a forced layout read out of the rAF loop.
  measureGrids() {
    this.grids = Array.from(document.querySelectorAll(".blueprint-grid")).map((el) => ({
      el,
      rect: el.getBoundingClientRect()
    }))
  }

  // Coarse pointers (touch) have no hover state to react to, and reduced motion
  // asks us not to move things at all.
  get enabled() {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return false
    return window.matchMedia("(hover: hover) and (pointer: fine)").matches
  }

  // The button classes already carry the magnetic transform in CSS, so they are
  // picked up here rather than requiring a `.magnetic` class on every call site.
  get magnetSelector() {
    return ".magnetic, .btn-primary, .btn-dark, .btn-outline"
  }

  handlePointerMove(event) {
    this.pointer.x = event.clientX
    this.pointer.y = event.clientY

    // Resolve the hovered element once per event rather than per frame; the
    // element under the pointer cannot change without a pointermove.
    const plate = event.target.closest?.(".plate") || null
    const magnet = event.target.closest?.(this.magnetSelector) || null

    // Clear the element we are leaving as soon as the active one changes,
    // otherwise every plate and button the pointer crosses stays frozen
    // mid-tilt until the pointer leaves the window entirely.
    if (plate !== this.activePlate) this.clearPlate(this.activePlate)
    if (magnet !== this.activeMagnet) this.clearMagnet(this.activeMagnet)

    this.activePlate = plate
    this.activeMagnet = magnet

    if (this.pending) return
    this.pending = true
    this.frameId = requestAnimationFrame(this.render)
  }

  render = () => {
    this.pending = false
    this.renderGrid()
    this.renderPlate()
    this.renderMagnet()
  }

  // The grid highlight follows the pointer across whichever section it is in.
  // Matching is geometric because the grids sit beneath the hero overlays.
  renderGrid() {
    const { x, y } = this.pointer

    const hit = this.grids.find(({ rect }) => (
      x >= rect.left && x <= rect.right && y >= rect.top && y <= rect.bottom
    ))
    if (!hit) return

    const { el, rect } = hit
    if (!rect.width || !rect.height) return

    el.style.setProperty("--mx", ((x - rect.left) / rect.width).toFixed(4))
    el.style.setProperty("--my", ((y - rect.top) / rect.height).toFixed(4))
  }

  renderPlate() {
    const plate = this.activePlate
    if (!plate) return

    const rect = plate.getBoundingClientRect()
    if (!rect.width || !rect.height) return

    const px = (this.pointer.x - rect.left) / rect.width
    const py = (this.pointer.y - rect.top) / rect.height

    // Pointer above centre tilts the top away from the viewer, which reads as
    // the plate leaning toward the cursor.
    plate.style.setProperty("--ry", `${((px - 0.5) * 2 * this.tiltMaxValue).toFixed(2)}deg`)
    plate.style.setProperty("--rx", `${((0.5 - py) * 2 * this.tiltMaxValue).toFixed(2)}deg`)
    plate.style.setProperty("--px", px.toFixed(4))
    plate.style.setProperty("--py", py.toFixed(4))
    plate.classList.add("is-tilting")
  }

  renderMagnet() {
    const magnet = this.activeMagnet
    if (!magnet) return

    const rect = magnet.getBoundingClientRect()
    if (!rect.width || !rect.height) return

    const dx = (this.pointer.x - (rect.left + rect.width / 2)) / (rect.width / 2)
    const dy = (this.pointer.y - (rect.top + rect.height / 2)) / (rect.height / 2)

    magnet.style.setProperty("--mag-x", `${(dx * this.magnetStrengthValue).toFixed(2)}px`)
    magnet.style.setProperty("--mag-y", `${(dy * this.magnetStrengthValue).toFixed(2)}px`)
    magnet.classList.add("is-magnetised")
  }

  clearPlate(plate) {
    if (!plate) return
    plate.classList.remove("is-tilting")
    plate.style.removeProperty("--rx")
    plate.style.removeProperty("--ry")
    plate.style.removeProperty("--px")
    plate.style.removeProperty("--py")
  }

  clearMagnet(magnet) {
    if (!magnet) return
    magnet.classList.remove("is-magnetised")
    magnet.style.removeProperty("--mag-x")
    magnet.style.removeProperty("--mag-y")
  }

  // Clears every effect when the pointer leaves the window, so nothing is left
  // frozen mid-tilt.
  reset() {
    document.querySelectorAll(".plate.is-tilting").forEach((plate) => this.clearPlate(plate))
    document.querySelectorAll(".is-magnetised").forEach((magnet) => this.clearMagnet(magnet))

    this.activePlate = null
    this.activeMagnet = null
  }
}

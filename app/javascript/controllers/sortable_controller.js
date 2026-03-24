import { Controller } from "@hotwired/stimulus"

// Drag-and-drop sortable list for newsletter content blocks.
// Uses the native HTML5 drag-and-drop API — no external library required.
export default class extends Controller {
  static targets = ["item"]
  static values  = { url: String }

  connect() {
    this.itemTargets.forEach(item => {
      item.setAttribute("draggable", "true")
      item.addEventListener("dragstart", this._dragStart.bind(this))
      item.addEventListener("dragover",  this._dragOver.bind(this))
      item.addEventListener("drop",      this._drop.bind(this))
      item.addEventListener("dragend",   this._dragEnd.bind(this))
    })
  }

  disconnect() {
    this.itemTargets.forEach(item => {
      item.setAttribute("draggable", "false")
    })
  }

  _dragStart(event) {
    this._dragging = event.currentTarget
    event.currentTarget.classList.add("opacity-50", "ring-2", "ring-indigo-400")
    event.dataTransfer.effectAllowed = "move"
  }

  _dragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    const target = event.currentTarget
    if (target !== this._dragging) {
      target.classList.add("border-t-2", "border-indigo-500")
    }
  }

  _drop(event) {
    event.preventDefault()
    const target = event.currentTarget
    if (target !== this._dragging) {
      target.classList.remove("border-t-2", "border-indigo-500")
      this.element.insertBefore(this._dragging, target)
      this._persistOrder()
    }
  }

  _dragEnd(event) {
    this._dragging?.classList.remove("opacity-50", "ring-2", "ring-indigo-400")
    this.itemTargets.forEach(i => i.classList.remove("border-t-2", "border-indigo-500"))
    this._dragging = null
  }

  _persistOrder() {
    if (!this.urlValue) return

    const ids = this.itemTargets.map(item => item.dataset.id)
    fetch(this.urlValue, {
      method:  "PATCH",
      headers: {
        "Content-Type":  "application/json",
        "X-CSRF-Token":  document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify({ order: ids })
    })
  }
}

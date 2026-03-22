import { Controller } from "@hotwired/stimulus"

// Kanban drag-and-drop for application pipeline
// Uses native HTML5 drag and drop
export default class extends Controller {
  static targets = ["column"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    this.element.querySelectorAll("[data-application-id]").forEach(card => {
      card.setAttribute("draggable", "true")
      card.addEventListener("dragstart", this.onDragStart.bind(this))
      card.addEventListener("dragend", this.onDragEnd.bind(this))
    })

    this.columnTargets.forEach(column => {
      column.addEventListener("dragover", this.onDragOver.bind(this))
      column.addEventListener("drop", this.onDrop.bind(this))
    })
  }

  onDragStart(event) {
    this.dragged = event.currentTarget
    event.currentTarget.classList.add("opacity-50")
    event.dataTransfer.effectAllowed = "move"
    event.dataTransfer.setData("text/plain", event.currentTarget.dataset.applicationId)
  }

  onDragEnd(event) {
    event.currentTarget.classList.remove("opacity-50")
  }

  onDragOver(event) {
    event.preventDefault()
    event.dataTransfer.dropEffect = "move"
    event.currentTarget.classList.add("ring-2", "ring-indigo-400")
  }

  onDrop(event) {
    event.preventDefault()
    const column = event.currentTarget
    column.classList.remove("ring-2", "ring-indigo-400")

    const applicationId = event.dataTransfer.getData("text/plain")
    const newStatus = column.dataset.status

    if (!applicationId || !newStatus) return

    // Append card to column visually
    if (this.dragged) {
      column.appendChild(this.dragged)
      this.dragged.dataset.status = newStatus
    }

    // Persist via PATCH
    this.updateApplicationStatus(applicationId, newStatus)
  }

  updateApplicationStatus(applicationId, newStatus) {
    const card = this.element.querySelector(`[data-application-id="${applicationId}"]`)
    if (!card) return

    // Find the update URL from the card's view link
    const viewLink = card.querySelector("a[href*='volunteer_applications']")
    if (!viewLink) return

    const showUrl = viewLink.getAttribute("href")
    const updateUrl = showUrl  // PATCH to same URL

    const formData = new FormData()
    formData.append("volunteer_application[status]", newStatus)
    formData.append("_method", "patch")

    fetch(updateUrl, {
      method: "POST",
      headers: {
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: formData
    })
  }
}

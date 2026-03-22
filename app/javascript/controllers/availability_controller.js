import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid"]

  connect() {
    this.renderGrid()
  }

  toggle(event) {
    const day = event.target.dataset.day
    const block = event.target.dataset.block
    event.target.classList.toggle("bg-indigo-500")
    event.target.classList.toggle("text-white")
    event.target.classList.toggle("bg-gray-100")
    this.updateHiddenField()
  }

  renderGrid() {
    const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    const blocks = ["Morning", "Afternoon", "Evening"]
    // Grid is rendered server-side; Stimulus handles interactivity
  }

  updateHiddenField() {
    const selected = []
    this.element.querySelectorAll(".availability-cell.bg-indigo-500").forEach(cell => {
      selected.push({ day: cell.dataset.day, block: cell.dataset.block })
    })
    const hiddenField = this.element.querySelector("input[name*='time_blocks']")
    if (hiddenField) {
      hiddenField.value = JSON.stringify(selected)
    }
  }
}

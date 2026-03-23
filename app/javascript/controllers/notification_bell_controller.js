import { Controller } from "@hotwired/stimulus"

// Manages the notification bell dropdown.
export default class extends Controller {
  static targets = ["dropdown"]

  connect() {
    this._closeOnOutsideClick = this._handleOutsideClick.bind(this)
    document.addEventListener("click", this._closeOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener("click", this._closeOnOutsideClick)
  }

  toggle(event) {
    event.stopPropagation()
    this.dropdownTarget.classList.toggle("hidden")
  }

  close() {
    this.dropdownTarget.classList.add("hidden")
  }

  _handleOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}

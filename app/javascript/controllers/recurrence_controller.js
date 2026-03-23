import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel"]

  toggle(event) {
    if (event.target.checked) {
      this.panelTarget.classList.remove("hidden")
    } else {
      this.panelTarget.classList.add("hidden")
    }
  }
}

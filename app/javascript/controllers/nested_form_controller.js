import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["template", "target", "fields"]

  initialize() {
    this._index = Date.now()
  }

  add(event) {
    event.preventDefault()
    const content = this.templateTarget.innerHTML.replace(/TEMPLATE_RECORD/g, this._index++)
    this.targetTarget.insertAdjacentHTML("beforeend", content)
  }

  remove(event) {
    event.preventDefault()
    const fields = event.target.closest("[data-nested-form-target='fields']")
    if (!fields) return

    const destroyField = fields.querySelector("[data-nested-form-target='destroy']")
    if (destroyField) {
      destroyField.value = "1"
      fields.style.display = "none"
    } else {
      fields.remove()
    }
  }
}

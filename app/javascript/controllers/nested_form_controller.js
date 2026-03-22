import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fields", "destroyField"]

  add(event) {
    event.preventDefault()
    const template = this.element.querySelector("template")
    if (template) {
      const content = template.content.cloneNode(true)
      const timestamp = new Date().getTime()
      content.querySelectorAll("input, select, textarea").forEach(input => {
        input.name = input.name.replace(/\[(\d+)\]/, `[${timestamp}]`)
        input.id = input.id.replace(/_(\d+)_/, `_${timestamp}_`)
      })
      this.element.insertBefore(content, event.target)
    }
  }

  remove(event) {
    event.preventDefault()
    const fieldsTarget = event.target.closest("[data-nested-form-target='fields']")
    if (fieldsTarget) {
      const destroyField = fieldsTarget.querySelector("[data-nested-form-target='destroyField']")
      if (destroyField) {
        destroyField.value = "1"
        fieldsTarget.style.display = "none"
      } else {
        fieldsTarget.remove()
      }
    }
  }
}

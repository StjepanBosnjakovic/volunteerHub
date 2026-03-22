import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }

  copy(event) {
    event.preventDefault()
    navigator.clipboard.writeText(this.textValue).then(() => {
      const original = event.currentTarget.textContent
      event.currentTarget.textContent = "✓ Copied!"
      setTimeout(() => { event.currentTarget.textContent = original }, 2000)
    })
  }
}

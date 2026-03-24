import { Controller } from "@hotwired/stimulus"

// Live segment preview for Broadcast Messages and Email Campaigns.
// Sends a GET request to the preview_segment endpoint and displays the
// estimated recipient count.
export default class extends Controller {
  static targets = ["count"]
  static values  = { previewUrl: String }

  connect() {
    this.preview()
  }

  preview() {
    const form    = this.element.closest("form")
    const params  = new URLSearchParams()

    const roleEl    = form.querySelector('[name="broadcast_message[segment_filters][role]"], [name="email_campaign[segment_filters][role]"]')
    const programEl = form.querySelector('[name="broadcast_message[segment_filters][program_id]"], [name="email_campaign[segment_filters][program_id]"]')
    const statusEl  = form.querySelector('[name="broadcast_message[segment_filters][volunteer_status]"], [name="email_campaign[segment_filters][volunteer_status]"]')

    if (roleEl?.value)    params.set("role",             roleEl.value)
    if (programEl?.value) params.set("program_id",       programEl.value)
    if (statusEl?.value)  params.set("volunteer_status", statusEl.value)

    const url = `${this.previewUrlValue}?${params.toString()}`

    fetch(url, {
      headers: {
        "Accept":            "application/json",
        "X-Requested-With":  "XMLHttpRequest",
        "X-CSRF-Token":      document.querySelector('meta[name="csrf-token"]')?.content
      }
    })
      .then(r => r.json())
      .then(data => {
        if (this.hasCountTarget) {
          this.countTarget.textContent = data.count
        }
      })
      .catch(() => {
        if (this.hasCountTarget) {
          this.countTarget.textContent = "–"
        }
      })
  }
}

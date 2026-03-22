import { Controller } from "@hotwired/stimulus"

// Handles bulk approve/decline on Kanban board
export default class extends Controller {
  submit(event) {
    event.preventDefault()

    const status = document.getElementById("bulk_status")?.value
    if (!status) return

    const checkedBoxes = document.querySelectorAll("input[name='application_ids[]']:checked")
    if (checkedBoxes.length === 0) {
      alert("Please select at least one application.")
      return
    }

    const form = document.createElement("form")
    form.method = "POST"
    form.action = event.currentTarget.closest("form")?.action || event.currentTarget.dataset.url

    const csrfInput = document.createElement("input")
    csrfInput.type = "hidden"
    csrfInput.name = "authenticity_token"
    csrfInput.value = document.querySelector('meta[name="csrf-token"]').content
    form.appendChild(csrfInput)

    const statusInput = document.createElement("input")
    statusInput.type = "hidden"
    statusInput.name = "status"
    statusInput.value = status
    form.appendChild(statusInput)

    checkedBoxes.forEach(box => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = "application_ids[]"
      input.value = box.value
      form.appendChild(input)
    })

    document.body.appendChild(form)
    form.submit()
  }
}

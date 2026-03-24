import { Controller } from "@hotwired/stimulus"

// Manages the message composer textarea.
// - Submit on Ctrl+Enter / Cmd+Enter
// - Clears input after successful form submission via Turbo
export default class extends Controller {
  static targets = ["input"]

  connect() {
    // Scroll messages container to bottom on load
    this._scrollToBottom()
  }

  submitOnEnter(event) {
    // Ctrl+Enter or Cmd+Enter to submit
    if ((event.ctrlKey || event.metaKey) && event.key === "Enter") {
      event.preventDefault()
      this.element.closest("form")?.requestSubmit()
    }
  }

  clearOnSuccess(event) {
    // Called after successful turbo-stream response
    if (this.hasInputTarget) {
      this.inputTarget.value = ""
      this.inputTarget.focus()
    }
    this._scrollToBottom()
  }

  _scrollToBottom() {
    const messages = document.getElementById("messages")
    if (messages) {
      messages.scrollTop = messages.scrollHeight
    }
  }
}

import { Controller } from "@hotwired/stimulus"

// Lightweight month/week/day calendar for volunteer self-scheduling
export default class extends Controller {
  static targets = ["grid", "title", "view"]
  static values = { year: Number, month: Number, viewMode: String }

  connect() {
    const now = new Date()
    this.yearValue = now.getFullYear()
    this.monthValue = now.getMonth()
    this.viewModeValue = "month"
    this.render()
  }

  prevMonth() {
    if (this.monthValue === 0) {
      this.monthValue = 11
      this.yearValue--
    } else {
      this.monthValue--
    }
    this.render()
  }

  nextMonth() {
    if (this.monthValue === 11) {
      this.monthValue = 0
      this.yearValue++
    } else {
      this.monthValue++
    }
    this.render()
  }

  render() {
    const date = new Date(this.yearValue, this.monthValue, 1)
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = date.toLocaleDateString("en-US", { month: "long", year: "numeric" })
    }
    // Actual shift data is rendered server-side via Turbo Frame
    // This controller handles navigation state
    this.dispatch("navigate", { detail: { year: this.yearValue, month: this.monthValue + 1 } })
  }
}

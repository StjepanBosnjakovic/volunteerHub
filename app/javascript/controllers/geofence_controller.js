import { Controller } from "@hotwired/stimulus"

// Geofenced auto-check-in stub
// Shows a check-in prompt when volunteer is within 200m of shift location
export default class extends Controller {
  static values = { lat: Number, lng: Number }

  connect() {
    if (!this.hasLatValue || !this.hasLngValue) return
    if (!navigator.geolocation) return

    navigator.geolocation.getCurrentPosition(
      (position) => this.checkProximity(position),
      () => {} // silently ignore errors
    )
  }

  checkProximity(position) {
    const userLat = position.coords.latitude
    const userLng = position.coords.longitude
    const distance = this.haversineDistance(userLat, userLng, this.latValue, this.lngValue)

    if (distance <= 200) {
      this.element.classList.remove("hidden")
    }
  }

  checkin() {
    const qrToken = this.element.dataset.qrToken
    if (qrToken) {
      window.location.href = `/checkin/${qrToken}`
    }
  }

  // Haversine formula — distance in metres
  haversineDistance(lat1, lng1, lat2, lng2) {
    const R = 6371000
    const φ1 = lat1 * Math.PI / 180
    const φ2 = lat2 * Math.PI / 180
    const Δφ = (lat2 - lat1) * Math.PI / 180
    const Δλ = (lng2 - lng1) * Math.PI / 180
    const a = Math.sin(Δφ / 2) ** 2 + Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) ** 2
    return R * 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a))
  }
}

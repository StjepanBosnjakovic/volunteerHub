import { Controller } from "@hotwired/stimulus"

// Leaflet-based map for opportunity location
// Leaflet must be loaded via CDN or importmap
export default class extends Controller {
  static values = {
    lat: Number,
    lng: Number,
    title: String
  }

  connect() {
    this.initMap()
  }

  disconnect() {
    if (this.map) {
      this.map.remove()
    }
  }

  initMap() {
    // Only load if Leaflet is available (loaded via CDN in the page head)
    if (typeof L === "undefined") {
      this.element.innerHTML = `<div class="flex items-center justify-center h-full text-gray-400 text-sm">
        Map unavailable — add Leaflet to load the map.
      </div>`
      return
    }

    this.map = L.map(this.element).setView([this.latValue, this.lngValue], 14)

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
    }).addTo(this.map)

    L.marker([this.latValue, this.lngValue])
      .addTo(this.map)
      .bindPopup(this.titleValue)
      .openPopup()
  }
}

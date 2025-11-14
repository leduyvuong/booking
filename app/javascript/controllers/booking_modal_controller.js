import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal"]

  connect() {
    console.log("BookingModal controller connected")
    // Listen for turbo:frame-load to show modal when content loads
    const frame = this.element.querySelector('turbo-frame[id="booking_modal"]')
    if (frame) {
      console.log("Found booking modal frame, adding listener")
      frame.addEventListener("turbo:frame-load", this.showModal.bind(this))
    } else {
      console.log("No booking modal frame found")
    }
  }

  disconnect() {
    const frame = this.element.querySelector('turbo-frame[id="booking_modal"]')
    if (frame) {
      frame.removeEventListener("turbo:frame-load", this.showModal.bind(this))
    }
  }

  showModal() {
    console.log("ShowModal called")
    // Show modal when content is loaded
    if (this.hasModalTarget) {
      console.log("Showing modal")
      this.modalTarget.classList.remove("hidden")
      this.modalTarget.classList.add("flex")
    } else {
      console.log("No modal target found")
    }
  }

  hideModal() {
    // Hide modal
    if (this.hasModalTarget) {
      this.modalTarget.classList.add("hidden")
      this.modalTarget.classList.remove("flex")
      // Clear the content
      this.modalTarget.innerHTML = ""
    }
  }

  closeOnBackdrop(event) {
    // Close modal when clicking backdrop
    if (event.target === this.modalTarget) {
      this.hideModal()
    }
  }
}

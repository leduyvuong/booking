import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    loadingText: String
  }

  activate(event) {
    if (this.element.dataset.loadingButtonState === "loading") return

    this.element.dataset.loadingButtonState = "loading"
    this.originalContent = this.element.innerHTML
    this.element.disabled = true
    this.element.classList.add("cursor-not-allowed", "opacity-80")

    const text = this.loadingTextValue || "Booking..."
    this.element.innerHTML = `
      <svg class="mr-2 h-4 w-4 animate-spin text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
        <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
        <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8v4a4 4 0 00-4 4H4z"></path>
      </svg>
      <span>${text}</span>
    `
  }
}

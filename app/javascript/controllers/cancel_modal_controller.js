import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "patientName", "form"]

  open(event) {
    event.preventDefault()
    const trigger = event.currentTarget
    const patientName = trigger.dataset.patientName
    const cancelUrl = trigger.dataset.cancelUrl

    if (patientName) {
      this.patientNameTarget.textContent = patientName
    }
    if (cancelUrl) {
      this.formTarget.action = cancelUrl
    }

    this.modalTarget.classList.remove("hidden")
  }

  close(event) {
    if (event) {
      event.preventDefault()
    }

    this.modalTarget.classList.add("hidden")
    this.formTarget.reset()
    this.formTarget.action = ""
  }
}

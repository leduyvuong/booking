import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["toast"]

  connect() {
    this.toastTargets.forEach((toast, index) => {
      window.setTimeout(() => this.fadeOut(toast), 4000 + index * 300)
    })
  }

  dismiss(event) {
    event.preventDefault()
    const toast = event.target.closest("[data-toast-target='toast']")
    if (toast) {
      this.fadeOut(toast)
    }
  }

  fadeOut(toast) {
    if (!toast) return

    toast.classList.add("transition", "transform", "duration-300", "ease-in-out", "opacity-0", "translate-x-2")
    window.setTimeout(() => {
      toast.remove()
      if (!this.hasToastTarget) {
        this.element.remove()
      }
    }, 300)
  }
}

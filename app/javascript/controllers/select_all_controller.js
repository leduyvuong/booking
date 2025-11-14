import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["source", "item"]

  toggleAll() {
    const checked = this.sourceTarget.checked
    this.itemTargets.forEach((checkbox) => {
      checkbox.checked = checked
    })
  }
}

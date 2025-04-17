import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["search"]

  connect() {
    this.timeout = null

    // Restaurar foco após atualização Turbo Frame
    document.addEventListener("turbo:frame-load", this.restoreFocus)
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this.restoreFocus)
  }

  submit(event) {
    clearTimeout(this.timeout)

    this.timeout = setTimeout(() => {
      const form = this.element.closest("form") || this.element.querySelector("form")
      if (form) form.requestSubmit()
    }, 300)
  }

  restoreFocus = () => {
    if (this.hasSearchTarget) {
      setTimeout(() => {
        this.searchTarget.focus()
        this.searchTarget.setSelectionRange(
          this.searchTarget.value.length,
          this.searchTarget.value.length
        )
      }, 50)
    }
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["label", "input", "status", "actions", "editButton"]

  connect() {
    this.originalValue = this.inputTarget.value
  }

  toggle(event) {
    event.preventDefault()
    this.labelTarget.classList.add("hidden")
    this.inputTarget.classList.remove("hidden")
    this.actionsTarget.classList.remove("hidden")
    this.editButtonTarget.classList.add("hidden")
    this.inputTarget.focus()
  }

  async saveClick(event) {
    const value = this.inputTarget.value.trim()
    const productId = this.inputTarget.dataset.productId

    if (value === this.originalValue || value === "") {
      this.cancel()
      return
    }

    this.statusTarget.textContent = "Salvando..."

    const response = await fetch(`/products/${productId}/customized_products`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ custom_name: value })
    })

    if (response.ok) {
      this.originalValue = value
      this.labelTarget.textContent = value
      this.statusTarget.textContent = "✔️ Salvo"
      setTimeout(() => { this.statusTarget.textContent = "" }, 2000)
      this.cancel()
    } else {
      this.statusTarget.textContent = "Erro ao salvar"
    }
  }

  cancel() {
    this.inputTarget.classList.add("hidden")
    this.actionsTarget.classList.add("hidden")
    this.editButtonTarget.classList.remove("hidden")
    this.labelTarget.classList.remove("hidden")
    this.inputTarget.value = this.originalValue
    this.statusTarget.textContent = ""
  }
}

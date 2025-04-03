import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "total"]

  connect() {
    console.log("UpdateTotalController connected")
  }

  update() {
    let total = 0
    this.checkboxTargets.forEach(cb => {
      if (cb.checked) {
        const price = parseFloat(cb.dataset.price)
        if (!isNaN(price)) {
          total += price
        }
      }
    })

    this.totalTarget.textContent = new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL"
    }).format(total)
  }

  checkSelection(event) {
    const anyChecked = this.checkboxTargets.some(cb => cb.checked)

    if (!anyChecked) {
      event.preventDefault()
      alert("Você precisa selecionar pelo menos um item para prosseguir.")
    }
  }
}

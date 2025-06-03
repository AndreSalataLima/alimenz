import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "total"]

  connect() {
    this.update()
  }

  update() {
    let total = 0

    this.checkboxTargets.forEach(cb => {
      if (cb.checked) {
        const price = parseFloat(cb.dataset.price)
        const quantity = parseFloat(cb.dataset.quantity)

        if (!isNaN(price) && !isNaN(quantity)) {
          total += price * quantity
        }
      }
    })

    this.totalTarget.textContent = this.formatCurrency(total)
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL"
    }).format(value)
  }
}

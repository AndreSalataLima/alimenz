import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "quantity", "total", "productTotal"]

  connect() {
    console.log("UpdateTotalController connected")
    this.update()
  }

  update() {
    let total = 0

    this.checkboxTargets.forEach(cb => {
      const itemId = cb.dataset.itemId
      const responseId = cb.dataset.responseId
      const price = parseFloat(cb.dataset.price)

      const quantityInput = this.quantityTargets.find(q => q.dataset.itemId === itemId)
      const quantity = parseFloat(quantityInput?.value)

      // Busca correta do subtotal do produto (span) com base no itemId e responseId
      const productTotalSpan = this.productTotalTargets.find(pt =>
        pt.dataset.itemId === itemId && pt.dataset.responseId === responseId
      )

      const subtotal = (!isNaN(price) && !isNaN(quantity)) ? price * quantity : 0

      if (productTotalSpan) {
        productTotalSpan.textContent = this.formatCurrency(subtotal)
      }

      if (cb.checked) {
        if (quantity > 0) {
          total += subtotal
        } else {
          cb.checked = false
        }
      }
    })

    this.totalTarget.textContent = this.formatCurrency(total)
  }

  checkSelection(event) {
    const anyValid = this.checkboxTargets.some(cb => {
      if (!cb.checked) return false
      const itemId = cb.dataset.itemId
      const quantityInput = this.quantityTargets.find(q => q.dataset.itemId === itemId)
      const quantity = parseFloat(quantityInput?.value || 0)
      return quantity > 0
    })

    if (!anyValid) {
      event.preventDefault()
      alert("Você precisa selecionar pelo menos um item com quantidade válida para prosseguir.")
    }
  }

  formatCurrency(value) {
    return new Intl.NumberFormat("pt-BR", {
      style: "currency",
      currency: "BRL"
    }).format(value)
  }
}

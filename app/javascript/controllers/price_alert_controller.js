// app/javascript/controllers/price_alert_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "priceInput", "modal", "modalList", "total", "quantity"];

  connect() {
    console.log("Price Alert Controller connected");
    this.element.addEventListener("submit", this.checkPrices.bind(this));
    this.updateAllTotals(); // Atualiza todos os totais na conexão
  }

  checkPrices(event) {
    const priceInputs = this.priceInputTargets;
    let zeroPriceItems = [];
    priceInputs.forEach(input => {
      if (!input.disabled && parseFloat(input.value) === 0) {
        zeroPriceItems.push(input.dataset.productName);
      }
    });
    if (zeroPriceItems.length > 0) {
      event.preventDefault();
      this.populateModal(zeroPriceItems);
      this.modalTarget.classList.remove("hidden");
    }
  }

  populateModal(items) {
    this.modalListTarget.innerHTML = "";
    items.forEach(name => {
      const li = document.createElement("li");
      li.textContent = name;
      this.modalListTarget.appendChild(li);
    });
  }

  closeModal() {
    this.modalTarget.classList.add("hidden");
  }

  updateTotal(event) {
    const input = event.target;
    let price = parseFloat(input.value) || 0;

    if (price < 0) {
      price = 0;
      input.value = "0.00";
    }

    const row = input.closest("tr");
    const quantity = parseFloat(row.querySelector("[data-price-alert-target='quantity']")?.textContent) || 0;
    const total = price * quantity;

    const totalSpan = row.querySelector("[data-price-alert-target='total']");
    if (totalSpan) {
      totalSpan.textContent = total.toLocaleString("pt-BR", {
        style: "currency",
        currency: "BRL"
      });
    }
  }


  updateAllTotals() {
    this.priceInputTargets.forEach(input => {
      const event = new Event("input");
      input.dispatchEvent(event);
    });
  }
}

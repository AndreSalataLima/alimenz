// app/javascript/controllers/price_alert_controller.js
import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "priceInput", "modal", "modalList"];

  connect() {
    console.log("Price Alert Controller connected");
    this.element.addEventListener("submit", this.checkPrices.bind(this));
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

  // Apenas fecha o modal, sem prosseguir com o submit
  closeModal() {
    this.modalTarget.classList.add("hidden");
  }
}

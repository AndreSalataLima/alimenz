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
      // Se o input estiver desabilitado, significa que o produto está indisponível
      if (!input.disabled && parseFloat(input.value) === 0) {
        // Obter o nome do produto a partir do data attribute
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

  confirm(event) {
    // Se o fornecedor confirmar, remova o listener para evitar loop e submeta o formulário.
    this.modalTarget.classList.add("hidden");
    // Remover o listener temporariamente para permitir o submit
    this.element.removeEventListener("submit", this.checkPrices.bind(this));
    this.element.submit();
  }

  cancel(event) {
    // Apenas fecha o modal para que o fornecedor possa revisar os preços
    this.modalTarget.classList.add("hidden");
  }

  togglePriceInput(event) {
    const checkbox = event.currentTarget;
    // Encontre o input de preço na mesma linha (você pode ajustar esse seletor conforme sua estrutura)
    const row = checkbox.closest("tr");
    const priceInput = row.querySelector('input[type="number"][data-price-alert-target="priceInput"]');
    if (checkbox.checked) {
      // Se estiver marcado (disponível), habilita o campo
      priceInput.disabled = false;
    } else {
      // Se não estiver disponível, desabilita o campo e limpa o valor (ou mantém o valor anterior)
      priceInput.disabled = true;
    }
  }

}

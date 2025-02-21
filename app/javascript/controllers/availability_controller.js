import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["price", "checkbox"];

  connect() {
    this.toggle(); // Ajusta o estado inicial
  }

  toggle() {
    this.priceTargets.forEach((priceInput, index) => {
      const isChecked = this.checkboxTargets[index].checked;
      // Se não estiver marcado (não disponível), desabilita o input
      // Caso esteja marcado, habilita
      priceInput.disabled = !isChecked;
    });
  }
}

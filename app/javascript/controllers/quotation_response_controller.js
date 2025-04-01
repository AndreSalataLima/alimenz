import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["expirationDate", "errorModal", "errorMessage"]

  submitForm(event) {
    const dateField = this.expirationDateTarget;
    if (!dateField || !dateField.value) {
      event.preventDefault();
      this.showErrorModal("A data de validade da resposta é obrigatória e deve ser futura.");
      return;
    }

    const selectedDate = new Date(dateField.value);
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (selectedDate <= today) {
      event.preventDefault();
      this.showErrorModal("A data de validade da resposta deve ser uma data futura.");
    }
  }

  showErrorModal(message) {
    this.errorMessageTarget.textContent = message;
    this.errorModalTarget.classList.remove("hidden");
  }

  closeErrorModal() {
    this.errorModalTarget.classList.add("hidden");
  }
}

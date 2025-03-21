// app/javascript/controllers/cotacao_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "unidadeSelect",
    "quantidade",
    "modal",
    "errorModal",
    "errorMessage",
    "confirmModal"
  ]

  connect() {
    console.log("Cotacao Controller conectado");
  }

  atualizarUnidades(event) {
    const produtoId = event.target.value;
    const produto = window.PRODUCTS.find(p => p.id === parseInt(produtoId));
    if (produto) {
      const opcoes = produto.opcoes_unidades?.length > 0
        ? produto.opcoes_unidades
        : [produto.unidade_sugerida];
      this.preencherUnidades(opcoes);
    }
  }

  preencherUnidades(opcoes) {
    this.unidadeSelectTarget.innerHTML = '<option value="">Selecione a unidade</option>';
    opcoes.forEach(opcao => {
      const option = document.createElement("option");
      option.value = opcao;
      option.text = opcao;
      const numerico = parseFloat(opcao.match(/[\d\.]+/)?.[0]) || 0;
      option.dataset.numerico = numerico;
      this.unidadeSelectTarget.appendChild(option);
    });
  }

  // Intercepta o submit do formulário para validar a data
  submitForm(event) {
    const dateField = this.element.querySelector("input[type='date'][name='quotation[expiration_date]']");
    if (!dateField || !dateField.value) {
      event.preventDefault();
      this.showErrorModal("A data de validade da cotação é obrigatória e deve ser futura.");
      return;
    }
    const selectedDate = new Date(dateField.value);
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    if (selectedDate <= today) {
      event.preventDefault();
      this.showErrorModal("A data de validade deve ser uma data futura.");
      return;
    }
    // Se a data estiver correta, exibe o modal de confirmação
    event.preventDefault();
    this.showConfirmModal();
  }

  showErrorModal(message) {
    this.errorMessageTarget.textContent = message;
    this.errorModalTarget.classList.remove("hidden");
  }

  fecharErrorModal() {
    this.errorModalTarget.classList.add("hidden");
  }

  showConfirmModal() {
    this.confirmModalTarget.classList.remove("hidden");
  }

  cancelSubmit() {
    this.confirmModalTarget.classList.add("hidden");
  }

  confirmSubmit() {
    this.confirmModalTarget.classList.add("hidden");
    const form = this.element.querySelector("form");
    if (form) {
      form.submit();
    }
  }

  mostrarModal() {
    this.modalTarget.classList.remove("hidden");
  }

  fecharModal() {
    this.modalTarget.classList.add("hidden");
  }
}

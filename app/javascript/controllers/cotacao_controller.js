import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "errorModal",
    "errorMessage",
    "confirmModal",
    "submitButton",
    "summaryTable"
  ]

  connect() {
    this.produtosAdicionados = new Set();
  }



  verificarCampos(event) {
    // Obtém a linha (row) do produto a partir do elemento que disparou o evento
    const row = event.currentTarget.closest("tr.product-item");
    const selectField = row.querySelector("select[data-cotacao-target='unidadeSelect']");
    const inputField = row.querySelector("input[name*='[quantity]']");
    const addButton = row.querySelector(".adicionar-lista-btn");

    const unidade = selectField.value;
    const quantidade = parseInt(inputField.value) || 0;

    if (unidade !== "" && quantidade > 0) {
      addButton.classList.remove("hidden");
    } else {
      addButton.classList.add("hidden");
    }
  }

  adicionarProduto(event) {
    const button = event.currentTarget;
    const row = button.closest("tr.product-item");
    const productId = row.dataset.productId;

    // Evita duplicidade na adição
    if (this.produtosAdicionados.has(productId)) {
      return;
    }

    // Obtém os dados do produto
    const productName = row.querySelector("td[data-controller='custom-name'] span[data-custom-name-target='label']").textContent.trim();
    const selectField = row.querySelector("select[data-cotacao-target='unidadeSelect']");
    const inputField = row.querySelector("input[name*='[quantity]']");
    const unidade = selectField.value;
    const quantidade = inputField.value;

    // Cria uma nova linha para a tabela de resumo (informativa)
    const summaryRow = document.createElement("tr");
    summaryRow.innerHTML = `
      <td class="px-2 py-1">${productName}</td>
      <td class="px-2 py-1">${quantidade}</td>
      <td class="px-2 py-1">${unidade}</td>
    `;

    // Adiciona a linha à tabela de resumo
    this.summaryTableTarget.appendChild(summaryRow);

    // Marca o produto como adicionado
    this.produtosAdicionados.add(productId);

    // Desabilita os campos do produto na tabela principal para evitar alterações
    selectField.disabled = true;
    inputField.disabled = true;
    button.classList.add("hidden");

    // Exibe o botão de envio, se ainda estiver oculto
    this.submitButtonTarget.classList.remove("hidden");
  }

  submitForm(event) {
    // Valida a data de validade da cotação
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
}

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

  if (this.produtosAdicionados.has(productId)) return;

  const unidadeSelect = row.querySelector("select");
  const quantidadeInput = row.querySelector("input[type='number']");

  // Garante que os campos sejam incluídos no POST
  unidadeSelect.disabled = false;
  quantidadeInput.disabled = false;

  // Remove readonly ou outras alterações
  unidadeSelect.removeAttribute("disabled");
  quantidadeInput.removeAttribute("disabled");

  // Exibe na tabela de resumo
  const productName = row.querySelector("span[data-custom-name-target='label']").textContent.trim();
  const unidade = unidadeSelect.value;
  const quantidade = quantidadeInput.value;

  const summaryRow = document.createElement("tr");
  summaryRow.innerHTML = `
    <td class="px-2 py-1">${productName}</td>
    <td class="px-2 py-1">${quantidade}</td>
    <td class="px-2 py-1">${unidade}</td>
  `;
  this.summaryTableTarget.appendChild(summaryRow);

  this.produtosAdicionados.add(productId);

  // Oculta o botão depois de adicionar
  button.classList.add("hidden");

  // Exibe botão de concluir cotação
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

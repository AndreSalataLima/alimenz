import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["fileFieldsContainer", "addFileButton", "resetButton", "modal"]

  connect() {
    this.pageNumber = 1; // Número da página inicial
    this.updateButtonsVisibility(); // Atualiza visibilidade dos botões ao iniciar
  }

  addFileField() {
    const container = this.fileFieldsContainerTarget;

    // Criando um novo campo de upload de arquivo
    const newField = document.createElement("div");
    newField.classList.add("mt-4", "file-field");
    newField.innerHTML = `
      <label class="file-label">Selecione a ${this.pageNumber + 1}ª página do documento</label>
      <input type="file" name="resposta_de_cotacao[documentos_assinados][]" class="border rounded px-2 py-1 file-input" data-action="change->upload-modal#handleFileSelection">
      <span class="file-name hidden"></span>
    `;

    container.appendChild(newField);
    this.pageNumber++; // Atualiza o número da página
    this.updateButtonsVisibility(); // Atualiza a visibilidade dos botões
  }

  handleFileSelection(event) {
    const input = event.target;
    const fileLabel = input.previousElementSibling;
    const fileNameDisplay = input.nextElementSibling;

    if (input.files.length > 0) {
      const fileName = input.files[0].name;
      fileLabel.textContent = `${this.pageNumber}ª página: `;
      fileNameDisplay.textContent = fileName;
      fileNameDisplay.classList.remove("hidden");
      input.classList.add("hidden"); // Esconde o campo de upload

      this.updateButtonsVisibility(); // Atualiza a visibilidade dos botões
    }
  }

  resetFiles() {
    // Remove todos os campos de arquivo existentes e reinicia o formulário
    this.fileFieldsContainerTarget.innerHTML = `
      <div class="mt-4 file-field">
        <label class="file-label">Selecione a cotação assinada ou a primeira página do documento</label>
        <input type="file" name="resposta_de_cotacao[documentos_assinados][]" class="border rounded px-2 py-1 file-input" data-action="change->upload-modal#handleFileSelection">
        <span class="file-name hidden"></span>
      </div>
    `;

    this.pageNumber = 1; // Reinicia a numeração das páginas
    this.updateButtonsVisibility(); // Atualiza a visibilidade dos botões
  }

  updateButtonsVisibility() {
    const files = this.fileFieldsContainerTarget.querySelectorAll(".file-input.hidden");

    // Mostra "Selecionar outro arquivo" apenas quando todas as imagens anteriores forem selecionadas
    if (files.length === this.pageNumber) {
      this.addFileButtonTarget.classList.remove("hidden");
    } else {
      this.addFileButtonTarget.classList.add("hidden");
    }

    // O botão "Recomeçar busca" aparece assim que pelo menos uma imagem for enviada
    if (files.length > 0) {
      this.resetButtonTarget.classList.remove("hidden");
    } else {
      this.resetButtonTarget.classList.add("hidden");
    }
  }

  openModal(event) {
    event.preventDefault(); // Impede o envio imediato
    this.modalTarget.classList.remove("hidden");
  }

  confirm(event) {
    event.preventDefault();
    this.modalTarget.classList.add("hidden");
    this.element.submit();
  }

  cancel(event) {
    event.preventDefault();
    this.modalTarget.classList.add("hidden");
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unidadeSelect", "quantidade", "total", "modal", "errorModal", "errorMessage"]

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

  calcularTotal(event) {
    const row = event.target.closest("tr");
    if (!row) return;

    const unidadeSelect = row.querySelector("[data-cotacao-target='unidadeSelect']");
    const quantidadeInput = row.querySelector("[data-cotacao-target='quantidade']");
    const totalSpan = row.querySelector("[data-cotacao-target='total']");

    const selectedOption = unidadeSelect.selectedOptions[0];
    if (!selectedOption) {
      totalSpan.textContent = "0";
      return;
    }

    const unidadeTexto = selectedOption.value.trim();
    const quantidade = parseInt(quantidadeInput.value) || 0;

    let resultadoTexto = "";
    const pacoteMatch = unidadeTexto.match(/^(\d+)\s*x\s*(\d+)\s*(\w+)$/i);
    if (pacoteMatch) {
      const multiplicador = parseInt(pacoteMatch[1]);
      const quantidadePorUnidade = parseInt(pacoteMatch[2]);
      const unidadeFinal = pacoteMatch[3];
      const totalPacotes = quantidade * multiplicador;
      resultadoTexto = `${totalPacotes} x ${quantidadePorUnidade} ${this.pluralize(totalPacotes, unidadeFinal)}`;
    } else {
      const unidadeMatch = unidadeTexto.match(/^(\d+)\s*(\D+)$/);
      if (unidadeMatch) {
        const valorNumerico = parseInt(unidadeMatch[1]);
        const unidadeFinal = unidadeMatch[2].trim();
        const total = quantidade * valorNumerico;
        resultadoTexto = `${total} ${unidadeFinal}`;
      } else {
        resultadoTexto = `${quantidade} ${this.pluralize(quantidade, unidadeTexto)}`;
      }
    }
    totalSpan.textContent = resultadoTexto;
  }

  pluralize(quantidade, unidade) {
    const pluralRegras = {
      "caixa": "caixas",
      "unidade": "unidades"
    };

    if (quantidade > 1 && pluralRegras[unidade]) {
      return pluralRegras[unidade];
    }
    return unidade;
  }

  // Método para interceptar o submit do formulário
  submitForm(event) {
    // Obtemos o input oculto preenchido pelo date_picker_controller
    const dateInput = document.querySelector("[data-date-picker-target='hiddenInput']");
    if (!dateInput || !dateInput.value) {
      event.preventDefault();
      this.showErrorModal("Acrescente uma data de validade à cotação.");
    }
  }

  // Exibe o modal de erro com a mensagem fornecida
  showErrorModal(message) {
    this.errorMessageTarget.textContent = message;
    this.errorModalTarget.classList.remove("hidden");
  }

  // Fecha o modal de erro
  fecharErrorModal() {
    this.errorModalTarget.classList.add("hidden");
  }

  mostrarModal() {
    this.modalTarget.classList.remove("hidden");
  }

  fecharModal() {
    this.modalTarget.classList.add("hidden");
  }
}

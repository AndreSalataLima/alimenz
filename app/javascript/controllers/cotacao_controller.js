import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["unidadeSelect", "quantidade", "total", "modal"]

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
    // Descobre qual linha do produto foi alterada
    const row = event.target.closest("tr");
    if (!row) return;

    const unidadeSelect = row.querySelector("[data-cotacao-target='unidadeSelect']");
    const quantidadeInput = row.querySelector("[data-cotacao-target='quantidade']");
    const totalSpan = row.querySelector("[data-cotacao-target='total']");

    // Obtém a unidade selecionada
    const selectedOption = unidadeSelect.selectedOptions[0];
    if (!selectedOption) {
      totalSpan.textContent = "0";
      return;
    }

    const unidadeTexto = selectedOption.value.trim(); // Ex: "5kg", "4 x 12 caixas", "caixa", "unidade"
    const quantidade = parseInt(quantidadeInput.value) || 0;

    // 1️⃣ Verifica se é um pacote (ex: "4 x 12 caixas")
    const pacoteMatch = unidadeTexto.match(/^(\d+)\s*x\s*(\d+)\s*(\w+)$/i);

    let resultadoTexto = "";
    if (pacoteMatch) {
      // Pacote detectado: "4 x 12 caixas"
      const multiplicador = parseInt(pacoteMatch[1]); // Ex: "4"
      const quantidadePorUnidade = parseInt(pacoteMatch[2]); // Ex: "12"
      const unidadeFinal = pacoteMatch[3]; // Ex: "caixas"

      const totalPacotes = quantidade * multiplicador;
      resultadoTexto = `${totalPacotes} x ${quantidadePorUnidade} ${this.pluralize(totalPacotes, unidadeFinal)}`;
    } else {
      // 2️⃣ Se não for pacote, verifica se contém um número no início (ex: "5kg")
      const unidadeMatch = unidadeTexto.match(/^(\d+)\s*(\D+)$/);

      if (unidadeMatch) {
        // Caso padrão: número + unidade (ex: "5kg")
        const valorNumerico = parseInt(unidadeMatch[1]); // Ex: "5"
        const unidadeFinal = unidadeMatch[2].trim(); // Ex: "kg"
        const total = quantidade * valorNumerico;
        resultadoTexto = `${total} ${unidadeFinal}`;
      } else {
        // 3️⃣ Caso contrário, é uma unidade simples (ex: "caixa", "unidade")
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

    return unidade; // Mantém no singular se quantidade = 1
  }

  mostrarModal() {
    this.modalTarget.classList.remove("hidden");
  }

  fecharModal() {
    this.modalTarget.classList.add("hidden");
  }
}

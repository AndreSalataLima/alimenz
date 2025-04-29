import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "errorModal", "errorMessage", "confirmModal", "submitButton",
    "summaryTable", "resumo", "produtoForm",
  ]

  connect() {
    this.produtosAdicionados = new Set()
  }

  verificarCampos(event) {
    const row = event.currentTarget.closest("tr.product-item")
    const unidade = row.querySelector("select").value
    const quantidade = parseFloat(row.querySelector("input[type='number']").value || 0)
    const botao = row.querySelector(".adicionar-lista-btn")

    if (unidade && quantidade > 0) {
      botao.classList.remove("hidden")
    } else {
      botao.classList.add("hidden")
    }
  }

  adicionarProduto(event) {
    const row = event.currentTarget.closest("tr.product-item")
    const productId = row.dataset.productId

    if (this.produtosAdicionados.has(productId)) return

    const nome = row.querySelector("[data-custom-name-target='label']").textContent.trim()
    const unidade = row.querySelector("select").value
    const quantidade = row.querySelector("input[type='number']").value
    const comentario = row.querySelector('input[name$="[product_comment]"]').value

    // === Adiciona visualmente ao resumo
    this.resumoTarget.classList.remove("hidden")

    const summaryRow = document.createElement("tr")
    summaryRow.dataset.productId = productId
    summaryRow.innerHTML = `
      <td class="px-2 py-1">${nome}</td>
      <td class="px-2 py-1">${comentario}</td>
      <td class="px-2 py-1">${quantidade}</td>
      <td class="px-2 py-1">${unidade}</td>
      <td class="px-2 py-1">
        <button type="button"
                class="text-red-600 hover:text-red-800 text-sm"
                data-action="click->cotacao#removerProduto"
                data-product-id="${productId}">
          ✖
        </button>
      </td>
    `
    this.summaryTableTarget.appendChild(summaryRow)

    // === Cria inputs invisíveis e válidos para o Rails
    const hiddenFields = document.createElement("div")
    hiddenFields.dataset.productId = productId
    hiddenFields.innerHTML = `
      <input type="hidden" name="quotation[quotation_items_attributes][${productId}][product_id]" value="${productId}">
      <input type="hidden" name="quotation[quotation_items_attributes][${productId}][quantity]" value="${quantidade}">
      <input type="hidden" name="quotation[quotation_items_attributes][${productId}][selected_unit]" value="${unidade}">
      <input type="hidden" name="quotation[quotation_items_attributes][${productId}][product_comment]" value="${comentario}">
    `
    document.getElementById("campos-selecionados").appendChild(hiddenFields)

    // Marcar como adicionado
    this.produtosAdicionados.add(productId)

    // Oculta botão de adicionar
    row.querySelector(".adicionar-lista-btn").classList.add("hidden")

    // Garante campos ativos
    row.querySelector("select").disabled = false
    row.querySelector("input[type='number']").disabled = false
    row.style.display = ""

    // Exibe botão de submit
    this.submitButtonTarget.classList.remove("hidden")
    this.resumoTarget.scrollIntoView({ behavior: "smooth" })
  }

  removerProduto(event) {
    const productId = event.currentTarget.dataset.productId

    this.produtosAdicionados.delete(productId)

    // Remove da tabela visual
    const rowResumo = this.summaryTableTarget.querySelector(`tr[data-product-id="${productId}"]`)
    if (rowResumo) rowResumo.remove()

    // Remove campos ocultos do form
    const hidden = document
      .getElementById("campos-selecionados")
      .querySelector(`div[data-product-id="${productId}"]`)
    if (hidden) hidden.remove()

    // Oculta área de resumo se vazia
    if (this.produtosAdicionados.size === 0) {
      this.resumoTarget.classList.add("hidden")
      this.submitButtonTarget.classList.add("hidden")
    }

    // Se ainda tiver a linha do produto visível, reativa ela
    const rowProduto = document.querySelector(`tr[data-product-id="${productId}"]`)
    if (rowProduto) {
      rowProduto.querySelector(".adicionar-lista-btn")?.classList.remove("hidden")
      const unidadeSelect = rowProduto.querySelector("select")
      const quantidadeInput = rowProduto.querySelector("input[type='number']")
      if (unidadeSelect) unidadeSelect.disabled = false
      if (quantidadeInput) {
        quantidadeInput.disabled = false
        quantidadeInput.value = "0"
        this.verificarCampos({ currentTarget: quantidadeInput })
      }
    }
  }


  atualizarCamposOcultos(event) {
    const row = event.currentTarget.closest("tr.product-item")
    const productId = row.dataset.productId
    if (!this.produtosAdicionados.has(productId)) return

    const unidade    = row.querySelector("select").value
    const quantidade = row.querySelector("input[type='number']").value
    const comentario = row.querySelector('input[name$="[product_comment]"]').value

    // Atualiza campos ocultos do Rails
    const hidden = document
      .getElementById("campos-selecionados")
      .querySelector(`div[data-product-id="${productId}"]`)

    if (hidden) {
      hidden.querySelector(`input[name*="[quantity]"]`).value        = quantidade
      hidden.querySelector(`input[name*="[selected_unit]"]`).value   = unidade
      hidden.querySelector(`input[name*="[product_comment]"]`).value = comentario
    }

    // Atualiza a linha do card de resumo
    const rowResumo = this.summaryTableTarget.querySelector(`tr[data-product-id="${productId}"]`)
    if (rowResumo) {
      rowResumo.children[1].textContent = comentario   // coluna Observação
      rowResumo.children[2].textContent = quantidade  // coluna Quantidade
      rowResumo.children[3].textContent = unidade     // coluna Unidade
    }
  }


  // --- Validação e envio
  submitForm(event) {
    const dateField = this.element.querySelector("input[name='quotation[expiration_date]']")
    const selectedDate = new Date(dateField.value)
    const today = new Date()
    today.setHours(0, 0, 0, 0)

    if (!dateField.value || selectedDate <= today) {
      event.preventDefault()
      this.showErrorModal("A data de validade é obrigatória e deve ser futura.")
      return
    }

    // 🧼 Remove campos de produtos não adicionados
    this.produtoFormTargets.forEach((row) => {
      const productId = row.dataset.productId
      if (!this.produtosAdicionados.has(productId)) {
        row.remove()
      }
    })

    event.preventDefault()
    this.showConfirmModal()
  }


  showErrorModal(message) {
    this.errorMessageTarget.textContent = message
    this.errorModalTarget.classList.remove("hidden")
  }

  fecharErrorModal() {
    this.errorModalTarget.classList.add("hidden")
  }

  showConfirmModal() {
    this.confirmModalTarget.classList.remove("hidden")
  }

  cancelSubmit() {
    this.confirmModalTarget.classList.add("hidden")
  }

  confirmSubmit() {
    this.confirmModalTarget.classList.add("hidden")
    document.getElementById("form-cotacao").submit()
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "errorModal", "errorMessage", "confirmModal", "submitButton",
    "summaryTable", "resumo", "produtoForm",
  ]

  connect() {
    this.produtosAdicionados = new Set()
    this.initializeItemsFromStorage()
    this.rebuildSummaryTable()
    this.rebuildHiddenInputs()
    document.addEventListener("turbo:frame-load", this._restoreFormState)
  }

  disconnect() {
    document.removeEventListener("turbo:frame-load", this._restoreFormState)
  }

  _restoreFormState = (event) => {
    if (event.target.id !== "produtos") return
    setTimeout(() => {
      this.restoreInputValuesFromStorage()
    }, 50)
  }

  initializeItemsFromStorage() {
    this.storedItems = JSON.parse(sessionStorage.getItem("quotationItems")) || {}
    Object.keys(this.storedItems).forEach(productId => {
      this.produtosAdicionados.add(productId)
    })
  }

  storeItemInStorage(productId, quantity, unit, comment, name) {
    this.storedItems[productId] = { quantity, unit, comment, name }
    sessionStorage.setItem("quotationItems", JSON.stringify(this.storedItems))
  }

  removeItemFromStorage(productId) {
    delete this.storedItems[productId]
    sessionStorage.setItem("quotationItems", JSON.stringify(this.storedItems))
  }

  rebuildHiddenInputs() {
    const container = document.getElementById("campos-selecionados")
    container.innerHTML = ""
    Object.keys(this.storedItems).forEach(productId => {
      const item = this.storedItems[productId]
      const hiddenFields = document.createElement("div")
      hiddenFields.dataset.productId = productId
      hiddenFields.innerHTML = `
        <input type="hidden" name="quotation[quotation_items_attributes][${productId}][product_id]" value="${productId}">
        <input type="hidden" name="quotation[quotation_items_attributes][${productId}][quantity]" value="${item.quantity}">
        <input type="hidden" name="quotation[quotation_items_attributes][${productId}][selected_unit]" value="${item.unit}">
        <input type="hidden" name="quotation[quotation_items_attributes][${productId}][product_comment]" value="${item.comment}">
      `
      container.appendChild(hiddenFields)
    })
  }

  rebuildSummaryTable() {
    this.summaryTableTarget.innerHTML = ""
    Object.keys(this.storedItems).forEach(productId => {
      const item = this.storedItems[productId]
      const summaryRow = document.createElement("tr")
      summaryRow.dataset.productId = productId
      summaryRow.innerHTML = `
        <td class="px-2 py-1">${item.name}</td>
        <td class="px-2 py-1">${item.comment}</td>
        <td class="px-2 py-1">${item.quantity}</td>
        <td class="px-2 py-1">${item.unit}</td>
        <td class="px-2 py-1">
          <button type="button" class="text-red-600 hover:text-red-800 text-sm" data-action="click->cotacao#removerProduto" data-product-id="${productId}">✖</button>
        </td>
      `
      this.summaryTableTarget.appendChild(summaryRow)
    })

    if (this.produtosAdicionados.size > 0) {
      this.resumoTarget.classList.remove("hidden")
      this.submitButtonTarget.classList.remove("hidden")
    } else {
      this.resumoTarget.classList.add("hidden")
      this.submitButtonTarget.classList.add("hidden")
    }
  }

  restoreInputValuesFromStorage() {
    Object.keys(this.storedItems).forEach(productId => {
      const item = this.storedItems[productId]
      const row = this.element.querySelector(`tr.product-item[data-product-id="${productId}"]`)
      if (!row) return

      const quantityInput = row.querySelector("input[type='number']")
      const unitSelect = row.querySelector("select")
      const commentInput = row.querySelector('input[name*="[product_comment]"]')
      const addButton = row.querySelector(".adicionar-lista-btn")

      if (quantityInput) quantityInput.value = item.quantity
      if (unitSelect) unitSelect.value = item.unit
      if (commentInput) commentInput.value = item.comment
      if (addButton) addButton.classList.add("hidden")
    })
  }

  adicionarProduto(event) {
    const row = event.currentTarget.closest("tr.product-item")
    const productId = row.dataset.productId
    const unidade = row.querySelector("select").value
    const quantidade = parseFloat(row.querySelector("input[type='number']").value || 0)

    if (!unidade || quantidade <= 0) {
      let msg = 'Favor selecionar '
      if (!unidade && quantidade <= 0) {
        msg += 'unidade e quantidade desejada.'
      } else if (!unidade) {
        msg += 'unidade.'
      } else {
        msg += 'quantidade.'
      }
      this.showErrorModal(msg)
      return
    }

    if (this.produtosAdicionados.has(productId)) return

    const nome = row.querySelector("[data-custom-name-target='label']").textContent.trim()
    const comentario = row.querySelector('input[name$="[product_comment]"]').value

    this.produtosAdicionados.add(productId)
    this.storeItemInStorage(productId, quantidade, unidade, comentario, nome)

    this.rebuildSummaryTable()
    this.rebuildHiddenInputs()

    row.querySelector(".adicionar-lista-btn").classList.add("hidden")
    this.resumoTarget.scrollIntoView({ behavior: "smooth" })
  }

  removerProduto(event) {
    const productId = event.currentTarget.dataset.productId
    this.produtosAdicionados.delete(productId)
    this.removeItemFromStorage(productId)

    this.rebuildSummaryTable()
    this.rebuildHiddenInputs()

    const rowProduto = document.querySelector(`tr[data-product-id="${productId}"]`)
    if (rowProduto) {
      rowProduto.querySelector(".adicionar-lista-btn")?.classList.remove("hidden")
      const quantidadeInput = rowProduto.querySelector("input[type='number']")
      if (quantidadeInput) {
        quantidadeInput.value = "0"
      }
    }
  }

  atualizarCamposOcultos(event) {
    const row = event.currentTarget.closest("tr.product-item")
    const productId = row.dataset.productId
    if (!this.produtosAdicionados.has(productId)) return

    const unidade = row.querySelector("select").value
    const quantidade = row.querySelector("input[type='number']").value
    const comentario = row.querySelector('input[name$="[product_comment]"]').value
    const nome = row.querySelector("[data-custom-name-target='label']").textContent.trim()

    this.storeItemInStorage(productId, quantidade, unidade, comentario, nome)
    this.rebuildSummaryTable()
    this.rebuildHiddenInputs()
  }

  submitForm(event) {
    event.preventDefault()

    const expirationField = this.element.querySelector("input[name='quotation[expiration_date]']")
    const responseField = this.element.querySelector("input[name='quotation[response_expiration_date]']")

    const expirationDate = new Date(expirationField.value)
    const responseDateParts = responseField.value.split("-")
    const responseDate = new Date(
      parseInt(responseDateParts[0]),
      parseInt(responseDateParts[1]) - 1,
      parseInt(responseDateParts[2])
    )

    const today = new Date()
    today.setHours(0, 0, 0, 0)

    const tomorrow = new Date()
    tomorrow.setDate(today.getDate() + 1)
    tomorrow.setHours(0, 0, 0, 0)

    if (!expirationField.value || expirationDate < tomorrow) {
      this.showErrorModal("A data de validade (conclusão de compra) deve ser, no mínimo, amanhã.")
      return
    }

    if (!responseField.value || responseDate <= today) {
      this.showErrorModal("A data limite de proposta é obrigatória e deve ser futura.")
      return
    }

    const minValidResponseDate = new Date(expirationDate)
    minValidResponseDate.setDate(minValidResponseDate.getDate() + 7)

    if (responseDate < minValidResponseDate) {
      const minDateStr = minValidResponseDate.toLocaleDateString('pt-BR')
      this.showErrorModal(`A validade mínima da proposta deve ser pelo menos 7 dias após a data desejada de conclusão da compra (${minDateStr}).`)
      return
    }

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
    const inputsDaTabela = this.element.querySelectorAll("#itens input, #itens select");
    inputsDaTabela.forEach(input => {
      input.disabled = true;
    });
    document.getElementById("form-cotacao").submit()
  }
}

// app/javascript/controllers/approval_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modalAprovar", "modalReprovar"]

  selecionarTodos() {
    this.element.querySelectorAll("input[type='checkbox']").forEach(checkbox => {
      checkbox.checked = true
    })
  }

  showAprovarModal(event) {
    event.preventDefault()

    const checkCarimbo = this.element.querySelector("#check_carimbo").checked
    const checkData = this.element.querySelector("#check_data").checked
    const checkProdutos = this.element.querySelector("#check_produtos").checked
    const checkValores = this.element.querySelector("#check_valores").checked

    let incompleteItems = []
    if (!checkCarimbo) incompleteItems.push("Carimbo e assinaturas legíveis")
    if (!checkData) incompleteItems.push("Data de validade válida")
    if (!checkProdutos) incompleteItems.push("Produtos da lista correspondem ao pedido de cotação")
    if (!checkValores) incompleteItems.push("Valores individuais do documento")

    const modal = this.modalAprovarTarget
    const titulo = modal.querySelector("#modalAprovarTitulo")
    const mensagem = modal.querySelector("#modalAprovarMensagem")

    if (incompleteItems.length === 0) {
      titulo.textContent = "Confirmar Aprovação"
      mensagem.innerHTML = "<p>Todos os itens estão marcados. Deseja confirmar a aprovação da cotação?</p>"
    } else {
      titulo.textContent = "Itens Incompletos"
      let html = "<p>Os seguintes itens não foram validados:</p><ul>"
      incompleteItems.forEach(item => {
        html += `<li>${item}</li>`
      })
      html += "</ul><p>Deseja confirmar a aprovação mesmo assim?</p>"
      mensagem.innerHTML = html
    }
    modal.classList.remove("hidden")
  }

  confirmarAprovacao(event) {
    event.preventDefault()
    const form = this.element.querySelector("form")

    // Adiciona um campo oculto "override" para sinalizar que o admin confirmou manualmente
    let overrideField = form.querySelector("input[name='override']")
    if (!overrideField) {
      overrideField = document.createElement("input")
      overrideField.type = "hidden"
      overrideField.name = "override"
      overrideField.value = "1"
      form.appendChild(overrideField)
    } else {
      overrideField.value = "1"
    }
    form.submit()
  }

  cancelarAprovacao() {
    this.modalAprovarTarget.classList.add("hidden")
  }

  showReprovarModal(event) {
    event.preventDefault()
    this.modalReprovarTarget.classList.remove("hidden")
  }

  confirmarReprovacao() {
    let form = document.createElement("form")
    form.method = "post"
    form.action = this.element.querySelector("#btnReprovar").getAttribute("data-action-url")

    let inputMethod = document.createElement("input")
    inputMethod.type = "hidden"
    inputMethod.name = "_method"
    inputMethod.value = "patch"
    form.appendChild(inputMethod)

    let csrfToken = document.querySelector("meta[name='csrf-token']").content
    let inputToken = document.createElement("input")
    inputToken.type = "hidden"
    inputToken.name = "authenticity_token"
    inputToken.value = csrfToken
    form.appendChild(inputToken)

    document.body.appendChild(form)
    form.submit()
  }

  cancelarReprovacao() {
    this.modalReprovarTarget.classList.add("hidden")
  }
}

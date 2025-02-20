import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["day", "month", "year", "hiddenInput", "error"]

  connect() {
    this.populateDays()
    this.populateMonths()
    this.populateYears()
  }

  populateDays() {
    const daySelect = this.dayTarget
    daySelect.innerHTML = '<option value="">Dia</option>'
    for (let i = 1; i <= 31; i++) {
      const option = document.createElement("option")
      option.value = i
      option.text = i
      daySelect.appendChild(option)
    }
  }

  populateMonths() {
    const monthSelect = this.monthTarget
    monthSelect.innerHTML = '<option value="">Mês</option>'
    const meses = [
      "Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho",
      "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"
    ]
    meses.forEach((mes, index) => {
      const option = document.createElement("option")
      option.value = index + 1
      option.text = mes
      monthSelect.appendChild(option)
    })
  }

  populateYears() {
    const yearSelect = this.yearTarget
    yearSelect.innerHTML = '<option value="">Ano</option>'
    const currentYear = new Date().getFullYear()
    // Permite anos de currentYear até currentYear + 10 (ajuste conforme necessário)
    for (let i = currentYear; i <= currentYear + 10; i++) {
      const option = document.createElement("option")
      option.value = i
      option.text = i
      yearSelect.appendChild(option)
    }
  }

  updateDate() {
    const day = parseInt(this.dayTarget.value)
    const month = parseInt(this.monthTarget.value)
    const year = parseInt(this.yearTarget.value)

    // Se algum dos valores não estiver selecionado, limpa o campo oculto e a mensagem de erro
    if (!day || !month || !year) {
      this.hiddenInputTarget.value = ""
      this.clearError()
      return
    }

    // Cria um objeto Date; lembre-se que o mês no JS começa em 0
    const date = new Date(year, month - 1, day)
    // Valida se a data realmente corresponde ao dia, mês e ano escolhidos
    if (date.getFullYear() !== year || date.getMonth() !== month - 1 || date.getDate() !== day) {
      this.hiddenInputTarget.value = ""
      this.showError("Data inválida.")
      return
    }

    // Verifica se a data é futura (considerando que hoje é válida apenas se for após a data atual)
    const today = new Date()
    today.setHours(0, 0, 0, 0) // Zera a parte do horário
    if (date <= today) {
      this.hiddenInputTarget.value = ""
      this.showError("A data deve ser futura.")
      return
    }

    // Se válida, formata como dd/mm/yyyy e atualiza o campo oculto
    const formattedDay = day.toString().padStart(2, "0")
    const formattedMonth = month.toString().padStart(2, "0")
    const formattedDate = `${formattedDay}/${formattedMonth}/${year}`
    this.hiddenInputTarget.value = formattedDate
    this.clearError()
  }

  showError(message) {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = message
      this.errorTarget.classList.remove("hidden")
    }
  }

  clearError() {
    if (this.hasErrorTarget) {
      this.errorTarget.textContent = ""
      this.errorTarget.classList.add("hidden")
    }
  }
}

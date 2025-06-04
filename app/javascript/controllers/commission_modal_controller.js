import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "message"];
  static values = {
    totalCommission: Number,
    paidTotal: Number
  }

  connect() {
    this.newTotal = null;
  }

  open() {
    if (this.paidTotalValue <= 0) {
      alert("Nenhum pagamento registrado. Não é possível marcar como pago integralmente.");
      return;
    }

    if (this.paidTotalValue === this.totalCommissionValue) {
      this.messageTarget.innerHTML = `Deseja confirmar que o valor de <strong>R$ ${this.formatCurrency(this.paidTotalValue)}</strong> foi totalmente pago?`;
      this.newTotal = null;
    } else {
      this.messageTarget.innerHTML = `A comissão de 5% era de <strong>R$ ${this.formatCurrency(this.totalCommissionValue)}</strong>.<br>Deseja confirmar que o novo valor total desta comissão será de <strong>R$ ${this.formatCurrency(this.paidTotalValue)}</strong>?`;
      this.newTotal = this.paidTotalValue;
    }

    this.modalTarget.classList.remove("hidden");
  }

  cancel(event) {
    event.preventDefault();
    this.modalTarget.classList.add("hidden");
  }

  confirm(event) {
    event.preventDefault();

    const url = `${window.location.pathname}/mark_paid_full`;

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": this.getCSRFToken()
      },
      body: JSON.stringify({
        new_total_commission: this.newTotal
      })
    }).then(response => {
      if (response.ok) {
        window.location.reload();
      } else {
        alert("Houve um erro ao atualizar. Tente novamente.");
        this.modalTarget.classList.add("hidden");
      }
    });
  }

  getCSRFToken() {
    return document.querySelector("meta[name='csrf-token']").getAttribute("content");
  }

  formatCurrency(value) {
    return value.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
}

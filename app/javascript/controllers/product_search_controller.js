import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"]

  connect() {
    console.log("Product Search Controller conectado!");
  }

  filtrar(event) {
    const term = event.target.value.toLowerCase();
    console.log(`🔍 Buscando: ${term}`);

    document.querySelectorAll("tbody tr.product-item").forEach(row => {
      const produtoNome = row.querySelector("td:first-child").textContent.toLowerCase();
      const visivel = produtoNome.includes(term);
      console.log(`🛒 Produto: ${produtoNome} - ${visivel ? "Mostrando" : "Escondendo"}`);
      row.style.display = visivel ? "table-row" : "none";
    });
  }
}

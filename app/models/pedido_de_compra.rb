class PedidoDeCompra < ApplicationRecord
  belongs_to :cliente, class_name: "Usuario", foreign_key: "cliente_id"
  belongs_to :fornecedor, class_name: "Usuario", foreign_key: "fornecedor_id"

  def calcular_comissao
    # A hierarquia pode ser:
    # 1. Comissão definida no Produto (para cada item)
    # 2. Caso não exista, usar a comissão na Subcategoria
    # 3. Caso não exista, usar a comissão na Categoria
    # 4. Caso nada esteja definido, usar a comissão do Fornecedor (campo commission_percentage em Usuario)
    #
    # Aqui você deve iterar pelos itens armazenados em `itens` e aplicar a lógica.
    # Este método é um exemplo e deve ser adaptado às suas regras.
    total_comissao = 0.0
    itens.each do |item|
      # Supondo que cada item seja um hash com chaves: "produto_id", "quantidade", "preco"
      produto = Produto.find(item["produto_id"])
      comissao_item = produto.commission_percentage ||
                      produto.subcategoria&.commission_percentage ||
                      produto.categoria&.commission_percentage ||
                      fornecedor.commission_percentage
      total_comissao += item["preco"].to_f * item["quantidade"].to_f * (comissao_item.to_f / 100)
    end
    total_comissao
  end
end

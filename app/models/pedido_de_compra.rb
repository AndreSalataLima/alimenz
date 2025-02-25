class PedidoDeCompra < ApplicationRecord
  belongs_to :cliente, class_name: "Usuario"
  belongs_to :fornecedor, class_name: "Usuario"

  # Cada pedido possui vários itens
  has_many :pedido_de_compra_items, dependent: :destroy

  # Caso queira criar os itens aninhados via form_with
  accepts_nested_attributes_for :pedido_de_compra_items, allow_destroy: true

  # Se o campo :itens (JSON) ainda existir, você pode removê-lo posteriormente
  # ou converter todos os dados para a nova tabela de itens.

  # Exemplo de método de cálculo de comissão, agora iterando sobre os itens do pedido
  def calcular_comissao
    total_comissao = 0.0
    pedido_de_compra_items.each do |item|
      produto = item.produto
      comissao_item = produto.commission_percentage ||
                      produto.subcategoria&.commission_percentage ||
                      produto.categoria&.commission_percentage ||
                      fornecedor.commission_percentage
      total_comissao += item.preco * item.quantidade * (comissao_item.to_f / 100)
    end
    total_comissao
  end
end

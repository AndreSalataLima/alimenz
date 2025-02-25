class PedidoDeCompraItem < ApplicationRecord
  belongs_to :pedido_de_compra
  belongs_to :produto

  # Exemplo de validações:
  validates :quantidade, numericality: { greater_than_or_equal_to: 0 }
  validates :preco, numericality: { greater_than_or_equal_to: 0 }
end

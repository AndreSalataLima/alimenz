class RespostaDeCotacaoItem < ApplicationRecord
  belongs_to :resposta_de_cotacao
  belongs_to :item_de_cotacao

  validates :preco, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

end

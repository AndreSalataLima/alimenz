class Produto < ApplicationRecord
  # belongs_to :categoria
  # belongs_to :subcategoria, optional: true
  has_many :itens_de_cotacao

  validates :nome_generico, presence: true
  validates :opcoes_unidades, presence: true

end

class Categoria < ApplicationRecord
  has_many :produtos
  has_many :fornecedor_categorias, dependent: :destroy
  has_many :fornecedores, through: :fornecedor_categorias, source: :fornecedor

end

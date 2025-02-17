class ProdutoCustomizado < ApplicationRecord
  belongs_to :cliente, class_name: "Usuario"
  belongs_to :produto

  validates :nome_customizado, presence: true
end

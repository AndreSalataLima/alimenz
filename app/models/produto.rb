class Produto < ApplicationRecord
  validates :nome, presence: true
  validates :nome_generico, presence: true
  validates :unidade_sugerida, presence: true
  
end

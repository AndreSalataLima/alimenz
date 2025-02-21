class Assinatura < ApplicationRecord
  belongs_to :usuario
  validates :imagem, presence: true
end

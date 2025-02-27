class Assinatura < ApplicationRecord
  belongs_to :usuario

  has_one_attached :imagem_assinatura
  has_one_attached :imagem_carimbo

  validates :imagem_assinatura, presence: true
end

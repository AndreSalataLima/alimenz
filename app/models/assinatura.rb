class Assinatura < ApplicationRecord
  belongs_to :usuario

  has_one_attached :imagem_assinatura

  validates :imagem_assinatura, presence: true
end

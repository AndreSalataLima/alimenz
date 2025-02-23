class RespostaDeCotacao < ApplicationRecord
  self.table_name = "resposta_de_cotacaos"

  attr_accessor :usar_assinatura_pre_cadastrada

  belongs_to :cotacao
  belongs_to :fornecedor, class_name: "Usuario", foreign_key: "fornecedor_id"
  has_many :resposta_de_cotacao_items, dependent: :destroy

  accepts_nested_attributes_for :resposta_de_cotacao_items, allow_destroy: true

  has_one_attached :documento_assinado

  VALID_STATUS_ANALISE = ["pendente_de_analise", "aprovado", "cotacao_nao_aceita"]
  validates :status_analise, inclusion: { in: VALID_STATUS_ANALISE }, allow_nil: true


  validates :status, inclusion: { in: ["pendente", "finalizado", "aguardando assinatura"] }
end

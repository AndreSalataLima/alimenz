class QuotationResponse < ApplicationRecord
  attr_accessor :use_pre_registered_signature

  belongs_to :quotation
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  has_many :quotation_response_items, dependent: :destroy

  accepts_nested_attributes_for :quotation_response_items, allow_destroy: true

  has_one_attached :signed_document

  VALID_ANALYSIS_STATUS = [ "pendente_de_analise", "aprovado", "cotacao_nao_aceita" ]
  validates :analysis_status, inclusion: { in: VALID_ANALYSIS_STATUS }, allow_nil: true

  validates :status, inclusion: { in: [ "pendente", "finalizado", "aguardando assinatura" ] }
end

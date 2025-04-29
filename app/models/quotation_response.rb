class QuotationResponse < ApplicationRecord
  attr_accessor :use_pre_registered_signature

  belongs_to :quotation
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  has_many :quotation_response_items, dependent: :destroy

  before_update :capture_supplier_snapshot, if: :freezing_state?

  accepts_nested_attributes_for :quotation_response_items, allow_destroy: true

  has_one_attached :signed_document

  VALID_ANALYSIS_STATUS = [ "pendente_de_analise", "aprovado", "cotacao_nao_aceita" ]
  validates :analysis_status, inclusion: { in: VALID_ANALYSIS_STATUS }, allow_nil: true

  validates :status, inclusion: { in: [ "pendente", "finalizado", "aguardando assinatura" ] }

  private

  def freezing_state?
    status_changed? && status == "finalizado"
  end

  def capture_supplier_snapshot
    self.supplier_snapshot = supplier.slice(
      'name', 'email', 'address', 'phone', 'cnpj', 'responsible', 'trade_name'
    )
  end
  
end

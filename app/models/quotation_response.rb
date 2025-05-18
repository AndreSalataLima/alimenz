class QuotationResponse < ApplicationRecord
  attr_accessor :use_pre_registered_signature

  belongs_to :quotation
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  has_many :quotation_response_items, dependent: :destroy

  before_update :capture_supplier_snapshot, if: :freezing_state?
  after_save :update_quotation_status_to_resposta_recebida

  accepts_nested_attributes_for :quotation_response_items, allow_destroy: true

  has_one_attached :signed_document

  enum :status, {
    aberta: 'aberta',
    aguardando_assinatura: 'aguardando_assinatura',
    revisao_fornecedor: 'revisao_fornecedor',
    documento_enviado: 'documento_enviado',
    visualizacao_liberada: 'visualizacao_liberada',
    arquivada: 'arquivada',
    concluida: 'concluida'
  }

  enum :analysis_status, {
    aberta: 'aberta',
    pendente_de_analise: 'pendente_de_analise',
    aprovado: 'aprovado',
    reprovado: 'reprovado'
  }


  private

  def freezing_state?
    status_changed? && status == "concluida"
  end

  def capture_supplier_snapshot
    self.supplier_snapshot = supplier.slice(
      'name', 'email', 'address', 'phone', 'cnpj', 'responsible', 'trade_name'
    )
  end

  def update_quotation_status_to_resposta_recebida
    return unless status == 'documento_enviado'

    quotation.update(status: 'resposta_recebida') if quotation.aberta?
  end

end

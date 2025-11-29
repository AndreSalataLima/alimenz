class PurchaseOrder < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :supplier, class_name: "User"
  belongs_to :quotation
  has_many :purchase_order_items, dependent: :destroy
  has_one :commission, dependent: :destroy

  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true

  after_commit :criar_commissao, on: [ :update ], if: :status_confirmada?
  after_commit :notify_creation_async, on: :create

  def status_confirmada?
    saved_change_to_status? && status == "confirmada"
  end

  def criar_commissao
    return if commission.present?

    valor_comissao = (total_value * BigDecimal("0.05")).round(2)
    Commission.create!(
      purchase_order: self,
      total_commission: valor_comissao
    )
  end

  enum :status, {
    aberta: "aberta",
    confirmada: "confirmada",
    arquivada: "arquivada"
  }

  private

  def notify_creation_async
    PurchaseOrderCreatedJob.perform_later(id)
  end
end

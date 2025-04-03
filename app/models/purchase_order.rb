class PurchaseOrder < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :supplier, class_name: "User"
  belongs_to :quotation

  has_many :purchase_order_items, dependent: :destroy

  accepts_nested_attributes_for :purchase_order_items, allow_destroy: true

  validates :status, inclusion: { in: %w[pendente confirmado cancelado enviado entregue] }

end

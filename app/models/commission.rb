class Commission < ApplicationRecord
  belongs_to :purchase_order
  has_many :commission_payments, dependent: :destroy

  validates :total_commission, presence: true, numericality: { greater_than_or_equal_to: 0 }

  def paid_total
    commission_payments.sum(:amount)
  end

  def remaining_amount
    total_commission - paid_total
  end

  def paid_in_full?
    paid_in_full
  end
end

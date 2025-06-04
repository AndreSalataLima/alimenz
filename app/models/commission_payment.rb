class CommissionPayment < ApplicationRecord
  belongs_to :commission

  validates :amount, numericality: { greater_than: 0 }
  validates :payment_date, presence: true
end

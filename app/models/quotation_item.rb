class QuotationItem < ApplicationRecord
  belongs_to :quotation
  belongs_to :product

  validates :quantity, presence: true
  validates :selected_unit, presence: true
end

class QuotationResponseItem < ApplicationRecord
  belongs_to :quotation_response
  belongs_to :quotation_item

  validates :price, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end

class QuotationResponseItem < ApplicationRecord
  belongs_to :quotation_response
  belongs_to :quotation_item

  validates :price, numericality: { greater_than: 0, message: "deve ser maior que zero" }
end

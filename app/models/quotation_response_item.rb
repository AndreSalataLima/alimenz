class QuotationResponseItem < ApplicationRecord
  belongs_to :quotation_response
  belongs_to :quotation_item
end

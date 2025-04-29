class BlockedSupplier < ApplicationRecord
  belongs_to :customer, class_name: 'User'
  belongs_to :supplier, class_name: 'User'

  validates :supplier_id, uniqueness: { scope: :customer_id }
end

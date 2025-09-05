class SupplierServedCity < ApplicationRecord
  belongs_to :supplier, class_name: "User"
  belongs_to :city

  validates :supplier_id, uniqueness: { scope: :city_id }
end

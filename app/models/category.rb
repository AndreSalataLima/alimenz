class Category < ApplicationRecord
  has_many :products
  has_many :supplier_categories, dependent: :destroy
  has_many :suppliers, through: :supplier_categories, source: :supplier
end

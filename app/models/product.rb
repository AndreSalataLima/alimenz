class Product < ApplicationRecord
  belongs_to :category

  has_many :quotation_items

  validates :generic_name, presence: true
  validates :unit_options, presence: true
end

class City < ApplicationRecord
  belongs_to :state

  has_many :supplier_served_cities, dependent: :destroy
  has_many :suppliers, through: :supplier_served_cities, source: :supplier

  validates :name, presence: true
end

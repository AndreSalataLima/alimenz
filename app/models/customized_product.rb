class CustomizedProduct < ApplicationRecord
  belongs_to :customer, class_name: "User"
  belongs_to :product

  validates :custom_name, presence: true
end

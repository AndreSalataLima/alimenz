class Signature < ApplicationRecord
  belongs_to :user

  has_one_attached :signature_image
  has_one_attached :stamp_image

  validates :signature_image, presence: true
end

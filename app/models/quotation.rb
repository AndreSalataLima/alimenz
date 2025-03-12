class Quotation < ApplicationRecord
  validates :expiration_date, presence: true

  belongs_to :customer, class_name: "User", foreign_key: "customer_id"
  has_many :quotation_items, dependent: :destroy
  has_many :quotation_responses, dependent: :destroy

  accepts_nested_attributes_for :quotation_items, allow_destroy: true,
                                reject_if: proc { |attributes| attributes['quantity'].to_f <= 0 || attributes['selected_unit'].blank? }

  after_create :generate_quotation_responses

  attribute :status, :string, default: 'pendente'

  private

  def generate_quotation_responses
    category_ids = quotation_items.map { |item| item.product.category_id }.uniq

    suppliers = User.joins(:supplier_categories)
                    .where(role: 'supplier', supplier_categories: { category_id: category_ids })
                    .distinct

    suppliers.each do |supplier|
      QuotationResponse.create!(
        quotation: self,
        supplier: supplier,
        status: "pendente",
        expiration_date: self.expiration_date
      )
    end
  end
end

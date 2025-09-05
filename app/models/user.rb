class User < ApplicationRecord
  has_one :signature, dependent: :destroy
  has_many :quotations, class_name: "Quotation", foreign_key: "customer_id", dependent: :destroy
  has_many :quotation_responses, foreign_key: "supplier_id", class_name: "QuotationResponse"
  has_many :supplier_categories, foreign_key: "supplier_id", class_name: "SupplierCategory", dependent: :destroy
  has_many :categories, through: :supplier_categories
  has_many :purchase_orders, foreign_key: "customer_id", class_name: "PurchaseOrder"
  has_many :customized_products, foreign_key: :customer_id, dependent: :destroy

  has_many :blocked_supplier_relationships,
           class_name: "BlockedSupplier",
           foreign_key: :customer_id,
           dependent: :destroy
  has_many :blocked_suppliers,
           through: :blocked_supplier_relationships,
           source: :supplier

  has_many :blocked_by_relationships,
           class_name: "BlockedSupplier",
           foreign_key: :supplier_id,
           dependent: :destroy
  has_many :blocker_customers,
           through: :blocked_by_relationships,
           source: :customer

  belongs_to :city, optional: true

  has_many :supplier_served_cities, foreign_key: :supplier_id, dependent: :destroy
  has_many :service_cities, through: :supplier_served_cities, source: :city

  def state
    city&.state
  end

  accepts_nested_attributes_for :signature

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  scope :customers, -> { where(role: "customer") }
  scope :suppliers, -> { where(role: "supplier") }
  scope :admins, -> { where(role: "admin") }

  validates :name, presence: true
  validates :role, inclusion: { in: %w[customer supplier admin] }
end

class SupplierCategory < ApplicationRecord
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  belongs_to :category

  after_create :include_supplier_in_open_quotations

  def include_supplier_in_open_quotations
    Quotation.where("expiration_date >= ?", Date.today).find_each do |quotation|
      if quotation.quotation_items.joins(:product)
              .where(products: { category_id: category_id }).exists?
        unless quotation.quotation_responses.exists?(supplier_id: supplier_id)
          quotation.quotation_responses.create!(
            supplier: supplier,
            status: "pendente",
            expiration_date: quotation.expiration_date
          )
        end
      end
    end
  end
end

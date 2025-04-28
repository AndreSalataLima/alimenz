class SupplierCategory < ApplicationRecord
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  belongs_to :category

  after_create :include_supplier_in_open_quotations

  def include_supplier_in_open_quotations
    Quotation.where("expiration_date >= ?", Date.today).find_each do |quotation|
      # só interessa se a cotação já tiver items dessa nova categoria
      if quotation.quotation_items.joins(:product)
                   .where(products: { category_id: category_id })
                   .exists? &&
         !quotation.quotation_responses.exists?(supplier_id: supplier_id)

        response = quotation.quotation_responses.create!(
          supplier: supplier,
          status: "pendente",
          expiration_date: quotation.expiration_date
        )

        # cria os response_items só para os quotation_items dessa categoria
        quotation.quotation_items.joins(:product)
                 .where(products: { category_id: category_id })
                 .find_each do |item|
          response.quotation_response_items.create!(quotation_item: item)
        end
      end
    end
  end
end

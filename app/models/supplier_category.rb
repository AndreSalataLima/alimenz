# app/models/supplier_category.rb
class SupplierCategory < ApplicationRecord
  belongs_to :supplier, class_name: "User", foreign_key: "supplier_id"
  belongs_to :category

  after_create :include_supplier_in_open_quotations
  after_destroy :mark_response_items_unavailable_for_removed_category

  private

  def include_supplier_in_open_quotations
    # Busca TODAS as categorias atuais do fornecedor
    supplier_category_ids = supplier.supplier_categories.pluck(:category_id)

    Quotation.where(status: [:aberta, :resposta_recebida, :expirada]).find_each do |quotation|
      next if quotation.customer.blocked_supplier_ids.include?(supplier_id)

      # Verifica se a cotação tem pelo menos 1 item de qualquer categoria do fornecedor
      matching_items = quotation.quotation_items.joins(:product)
                          .where(products: { category_id: supplier_category_ids })

      next unless matching_items.exists?

      # Busca ou cria a QuotationResponse
      response = quotation.quotation_responses.find_or_initialize_by(supplier: supplier)
      if response.new_record?
        response.status = "aberta"
        response.analysis_status = "analise_aberta"
        response.expiration_date = quotation.expiration_date
        response.save!
      end

      # Agora, garante que TODOS os itens das categorias do fornecedor estão presentes
      matching_items.find_each do |item|
        unless response.quotation_response_items.exists?(quotation_item_id: item.id)
          response.quotation_response_items.create!(quotation_item: item)
        end
      end
    end
  end

  def mark_response_items_unavailable_for_removed_category
    Quotation.joins(:quotation_items)
      .where("quotation_items.product_id IN (?)", Product.where(category_id: category_id).select(:id))
      .where(status: [:aberta, :resposta_recebida, :expirada])
      .find_each do |quotation|

      response = quotation.quotation_responses.find_by(supplier: supplier)
      next if response.nil?

      # Desativa os response_items ligados a itens da categoria que foi removida
      response.quotation_response_items.joins(quotation_item: :product)
        .where(products: { category_id: category_id })
        .update_all(available: false)
    end
  end
  
end

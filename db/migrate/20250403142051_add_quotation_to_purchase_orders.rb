class AddQuotationToPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    add_reference :purchase_orders, :quotation, foreign_key: true
  end
end

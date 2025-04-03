class MakeQuotationIdNotNullOnPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    change_column_null :purchase_orders, :quotation_id, false
  end
end

class AddGeneralCommentToPurchaseOrders < ActiveRecord::Migration[8.0]
  def change
    add_column :purchase_orders, :general_comment, :text
  end
end

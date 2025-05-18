class ChangePurchaseOrderStatusDefaultToAberto < ActiveRecord::Migration[8.0]
  def up
    change_column_default :purchase_orders, :status, from: "pendente", to: "aberto"
    PurchaseOrder.where(status: "pendente").update_all(status: "aberto")
  end

  def down
    PurchaseOrder.where(status: "aberto").update_all(status: "pendente")
    change_column_default :purchase_orders, :status, from: "aberto", to: "pendente"
  end
end

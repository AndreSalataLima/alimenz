class PurchaseOrderCreatedJob < ApplicationJob
  queue_as :default

  def perform(purchase_order_id)
    po = PurchaseOrder.find_by(id: purchase_order_id)
    return unless po
    NotificationService.purchase_order_created(po)
  end
end

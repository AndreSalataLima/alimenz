class SupplierReminderJob < ApplicationJob
  queue_as :default

  def perform(quotation_response_id, type)
    qr = QuotationResponse.find_by(id: quotation_response_id)
    return unless qr

    # Envia somente se ainda estiver pendente
    return unless qr.status == "aberta"

    NotificationService.supplier_reminder(qr, type.to_sym)
  end
end

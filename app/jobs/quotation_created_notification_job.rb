class QuotationCreatedNotificationJob < ApplicationJob
  queue_as :default

  def perform(quotation_id)
    quotation = Quotation.find_by(id: quotation_id)
    return unless quotation
    NotificationService.ong_quotation_created(quotation)
  end
end

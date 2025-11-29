class QuotationResponseCreatedNotificationJob < ApplicationJob
  queue_as :default

  def perform(quotation_response_id)
    qr = QuotationResponse.find_by(id: quotation_response_id)
    return unless qr

    if qr.status == "aberta"
      NotificationService.supplier_quotation_response_opened(qr)
    end

    schedule_reminders(qr)
  end

  private

  def schedule_reminders(qr)
    q = qr.quotation
    now = Time.current

    two_days_after_launch = (q.created_at + 2.days)
    SupplierReminderJob.set(wait_until: two_days_after_launch).perform_later(qr.id, :after_2_days) if two_days_after_launch > now

    if q.expiration_date.present?
      one_day_before = q.expiration_date.to_time.in_time_zone.change(hour: 9) - 1.day
      SupplierReminderJob.set(wait_until: one_day_before).perform_later(qr.id, :one_day_before) if one_day_before > now

      on_due = q.expiration_date.to_time.in_time_zone.change(hour: 9)
      SupplierReminderJob.set(wait_until: on_due).perform_later(qr.id, :on_due_day) if on_due > now
    end
  end
end

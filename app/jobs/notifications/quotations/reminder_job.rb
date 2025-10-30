module Notifications
  module Quotations
    class ReminderJob < ApplicationJob
      queue_as :default

      def perform(record_type, record_id, trigger)
        record = locate_record(record_type, record_id)
        unless record
          Rails.logger.warn("[Notifications::Quotations::ReminderJob] Registro #{record_type}##{record_id} não encontrado.")
          return
        end

        ReminderService.new(record: record).deliver(trigger)
      end

      private

      def locate_record(record_type, record_id)
        record_type.constantize.find_by(id: record_id)
      rescue NameError => error
        Rails.logger.error("[Notifications::Quotations::ReminderJob] Tipo de registro desconhecido #{record_type}: #{error.message}")
        nil
      end
    end
  end
end

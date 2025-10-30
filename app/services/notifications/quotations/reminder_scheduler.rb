module Notifications
  module Quotations
    class ReminderScheduler
      Trigger = Struct.new(:key, :time_calculator, keyword_init: true)

      TRIGGERS = [
        Trigger.new(
          key: "two_days_after_creation",
          time_calculator: ->(record) do
            timestamp = safe_time(record.created_at)
            timestamp ? timestamp + 2.days : nil
          end
        ),
        Trigger.new(
          key: "one_day_before_expiration",
          time_calculator: ->(record) do
            timestamp = expiration_time(record)
            timestamp ? timestamp - 1.day : nil
          end
        ),
        Trigger.new(key: "on_expiration_day", time_calculator: ->(record) { expiration_time(record) })
      ].freeze

      def self.safe_time(value)
        return if value.blank?

        value.is_a?(Time) || value.is_a?(ActiveSupport::TimeWithZone) ? value : value.to_time.in_time_zone
      end

      def self.expiration_time(record)
        return unless record.respond_to?(:expiration_date)

        date = record.expiration_date
        return if date.blank?

        Time.zone.local(date.year, date.month, date.day, 9, 0, 0)
      end

      private_class_method :safe_time, :expiration_time

      def initialize(record:, job_class: Notifications::Quotations::ReminderJob, logger: Rails.logger)
        @record = record
        @job_class = job_class
        @logger = logger
      end

      def schedule_all
        TRIGGERS.each do |trigger|
          schedule_trigger(trigger)
        end
      end

      private

      attr_reader :record, :job_class, :logger

      def schedule_trigger(trigger)
        timestamp = trigger.time_calculator.call(record)
        return unless timestamp

        timestamp = timestamp.in_time_zone if timestamp.respond_to?(:in_time_zone)
        return unless timestamp.future?

        job_class.set(wait_until: timestamp).perform_later(record.class.name, record.id, trigger.key)
        logger.info("[Notifications::Quotations::ReminderScheduler] Lembrete '#{trigger.key}' agendado para #{record_descriptor} em #{timestamp}.")
      rescue StandardError => error
        logger.error("[Notifications::Quotations::ReminderScheduler] Falha ao agendar '#{trigger.key}' para #{record_descriptor}: #{error.message}")
        raise
      end

      def record_descriptor
        "#{record.class.name}##{record.id}"
      end
    end
  end
end

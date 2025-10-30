module Notifications
  module Quotations
    class ReminderService
      TRIGGERS = {
        "two_days_after_creation" => "2 dias após a criação",
        "one_day_before_expiration" => "1 dia antes do vencimento",
        "on_expiration_day" => "no dia do vencimento"
      }.freeze

      def initialize(record:, email_provider: Providers::EmailProvider.new, whatsapp_provider: Providers::WhatsappProvider.new, logger: Rails.logger)
        @record = record
        @email_provider = email_provider
        @whatsapp_provider = whatsapp_provider
        @logger = logger
      end

      def deliver(trigger)
        trigger_key = trigger.to_s
        raise ArgumentError, "gatilho desconhecido: #{trigger}" unless TRIGGERS.key?(trigger_key)

        recipients = recipients_for(record)
        if recipients.empty?
          logger.info("[Notifications::Quotations::ReminderService] Nenhum destinatário encontrado para #{record_descriptor}.")
          return
        end

        subject = build_subject
        body = build_body(trigger_key)

        logger.info("[Notifications::Quotations::ReminderService] Enviando lembrete '#{trigger_key}' para #{record_descriptor} (#{recipients.size} destinatários).")

        recipients.each do |recipient|
          deliver_email(recipient, subject, body)
          deliver_whatsapp(recipient, body)
        end
      end

      private

      attr_reader :record, :email_provider, :whatsapp_provider, :logger

      def recipients_for(record)
        if record.is_a?(::Quotation)
          record.quotation_responses.includes(:supplier).map(&:supplier).compact.uniq.map do |supplier|
            { name: supplier.name, email: supplier.email, phone: supplier.phone }
          end
        elsif record.is_a?(::QuotationResponse)
          supplier = record.supplier
          supplier ? [ { name: supplier.name, email: supplier.email, phone: supplier.phone } ] : []
        else
          raise ArgumentError, "Registro não suportado: #{record.class.name}"
        end
      end

      def build_subject
        "[Alimenz] Lembrete da cotação #{quotation_title}"
      end

      def build_body(trigger_key)
        base_message = if record.is_a?(::Quotation)
          "A cotação '#{quotation_title}' requer sua atenção"
        else
          "Sua resposta para a cotação '#{quotation_title}' requer sua atenção"
        end

        "#{base_message}. Este é um lembrete enviado #{TRIGGERS.fetch(trigger_key)}."
      end

      def deliver_email(recipient, subject, body)
        return if recipient[:email].blank?

        personalized_body = <<~BODY
          Olá #{recipient[:name]},

          #{body}

          Obrigado,
          Equipe Alimenz
        BODY

        email_provider.deliver(recipient: recipient[:email], subject: subject, body: personalized_body)
      end

      def deliver_whatsapp(recipient, body)
        return if recipient[:phone].blank?

        message = "Olá #{recipient[:name]}, #{body}"
        whatsapp_provider.deliver(phone: recipient[:phone], message: message)
      end

      def quotation_title
        if record.is_a?(::Quotation)
          record.title.presence || "sem título"
        else
          record.quotation.title.presence || "sem título"
        end
      end

      def record_descriptor
        if record.is_a?(::Quotation)
          "Quotation##{record.id}"
        else
          "QuotationResponse##{record.id}"
        end
      end
    end
  end
end

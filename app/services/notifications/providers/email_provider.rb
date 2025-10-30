module Notifications
  module Providers
    class EmailProvider
      def initialize(mailer: ActionMailer::Base, from: default_from, logger: Rails.logger)
        @mailer = mailer
        @from = from
        @logger = logger
      end

      def deliver(recipient:, subject:, body:)
        message = mailer.mail(to: recipient, from: from, subject: subject, body: body)
        message.deliver_now
        logger.info("[Notifications::Providers::EmailProvider] Email enviado para #{recipient} com assunto '#{subject}'.")
      rescue StandardError => error
        logger.error("[Notifications::Providers::EmailProvider] Falha ao enviar e-mail para #{recipient}: #{error.message}")
        raise
      end

      private

      attr_reader :mailer, :from, :logger

      def default_from
        Rails.application.config.x.notifications.default_email_from
      end
    end
  end
end

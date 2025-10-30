module Notifications
  module Providers
    class WhatsappProvider
      class NullClient
        def send_message(phone:, message:)
          Rails.logger.info("[Notifications::Providers::WhatsappProvider::NullClient] WhatsApp para #{phone}: #{message}")
        end
      end

      def initialize(client: default_client, logger: Rails.logger)
        @client = client
        @logger = logger
      end

      def deliver(phone:, message:)
        client.send_message(phone: phone, message: message)
        logger.info("[Notifications::Providers::WhatsappProvider] Mensagem enviada para #{phone}.")
      rescue StandardError => error
        logger.error("[Notifications::Providers::WhatsappProvider] Falha ao enviar mensagem para #{phone}: #{error.message}")
        raise
      end

      private

      attr_reader :client, :logger

      def default_client
        Rails.application.config.x.notifications.whatsapp_client || NullClient.new
      end
    end
  end
end

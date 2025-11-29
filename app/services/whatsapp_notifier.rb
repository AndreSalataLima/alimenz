class WhatsappNotifier
  def initialize
    @enabled = ActiveModel::Type::Boolean.new.cast(
      Rails.application.credentials.dig(:whatsapp, :enabled)
    )
    return unless @enabled

    require "twilio-ruby"
    @client = Twilio::REST::Client.new(
      Rails.application.credentials.dig(:twilio, :account_sid),
      Rails.application.credentials.dig(:twilio, :auth_token)
    )
    @from = Rails.application.credentials.dig(:twilio, :whatsapp_from) # ex: "whatsapp:+14155238886"
  end

  def enabled?
    !!@enabled
  end

  def send_message(to_phone, body)
    return unless enabled?
    to = to_phone.to_s.strip
    to = "whatsapp:#{to}" unless to.start_with?("whatsapp:")
    @client.messages.create(from: @from, to: to, body: body)
  rescue => e
    Rails.logger.error("[WhatsApp] #{e.class}: #{e.message}")
    nil
  end
end

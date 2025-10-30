Rails.application.config.x.notifications = ActiveSupport::OrderedOptions.new unless Rails.application.config.x.respond_to?(:notifications)

Rails.application.config.x.notifications.default_email_from = ENV.fetch("NOTIFICATIONS_EMAIL_FROM", "no-reply@alimenz.local")
Rails.application.config.x.notifications.whatsapp_client = nil

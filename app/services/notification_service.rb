# frozen_string_literal: true

class NotificationService
  class << self
    # 2) Confirmação à ONG quando a cotação é criada
    def ong_quotation_created(quotation)
      OngMailer.quotation_created(quotation).deliver_later

      begin
        whatsapp = WhatsappNotifier.new
        if whatsapp.respond_to?(:enabled?) && whatsapp.enabled?
          ong = quotation.customer
          body = "Sua cotação ##{quotation.id} (#{quotation.title}) foi criada na Alimenz. " \
                 "Prazo resposta: #{quotation.response_expiration_date.strftime('%d/%m/%Y')}."
          whatsapp.send_message(ong.phone, body)
        else
          Rails.logger.info(
            "[WhatsApp][SIMULATION] ong_quotation_created " \
            "quotation_id=#{quotation.id} customer_phone=#{quotation.customer&.phone}"
          )
        end
      rescue => e
        Rails.logger.error("[WhatsApp] Falha ao notificar ONG na criação da cotação ##{quotation.id}: #{e.message}")
      end
    end

    # 3) Convite inicial ao fornecedor ao criar QuotationResponse
    def supplier_quotation_response_opened(qr)
      SupplierMailer.quotation_response_opened(qr).deliver_later

      begin
        whatsapp = WhatsappNotifier.new
        if whatsapp.respond_to?(:enabled?) && whatsapp.enabled?
          supplier = qr.supplier
          q = qr.quotation
          prazo = (qr.expiration_date || q.response_expiration_date)
          body = [
            "Você tem uma nova cotação para responder na Alimenz.",
            "Cotação ##{q.id} — #{q.title}",
            ("Prazo: #{prazo.strftime('%d/%m/%Y')}" if prazo).to_s
          ].reject(&:blank?).join(" | ")
          whatsapp.send_message(supplier.phone, body)
        else
          Rails.logger.info(
            "[WhatsApp][SIMULATION] supplier_invite " \
            "qr_id=#{qr.id} supplier_id=#{qr.supplier_id} quotation_id=#{qr.quotation_id}"
          )
        end
      rescue => e
        Rails.logger.error("[WhatsApp] Falha ao notificar fornecedor (qr_id=#{qr.id}): #{e.message}")
      end
    end

    # 4) Lembretes automáticos ao fornecedor (2d após, 1d antes, dia D)
    # type: :after_2_days | :one_day_before | :on_due_day
    def supplier_reminder(qr, type)
      q = qr.quotation
      supplier = qr.supplier
      prazo = (qr.expiration_date || q.response_expiration_date)

      # E-mail
      SupplierMailer.quotation_response_reminder(qr, type).deliver_later

      # WhatsApp
      begin
        whatsapp = WhatsappNotifier.new
        if whatsapp.respond_to?(:enabled?) && whatsapp.enabled?
          parts = []
          parts << "Lembrete: responda à cotação ##{q.id} — #{q.title}"
          parts << "Prazo: #{prazo.strftime('%d/%m/%Y')}" if prazo.present?

          case type.to_sym
          when :after_2_days   then parts << "(2 dias após o lançamento)"
          when :one_day_before then parts << "(faltam 24h)"
          when :on_due_day     then parts << "(vence hoje)"
          end

          whatsapp.send_message(supplier.phone, parts.join(" | "))
        else
          Rails.logger.info(
            "[WhatsApp][SIMULATION] supplier_reminder type=#{type} " \
            "qr_id=#{qr.id} supplier_id=#{qr.supplier_id} quotation_id=#{qr.quotation_id}"
          )
        end
      rescue => e
        Rails.logger.error("[WhatsApp] Falha no lembrete (qr_id=#{qr.id}, type=#{type}): #{e.message}")
      end
    end

    def admin_notify_available_quotations(quotation)
      ong = quotation.customer

      OngMailer.quotations_available(ong, quotation).deliver_later

      begin
        whatsapp = WhatsappNotifier.new
        if whatsapp.respond_to?(:enabled?) && whatsapp.enabled?
          msg = "Há cotações disponíveis na Alimenz. Ex.: ##{quotation.id} — #{quotation.title}."
          whatsapp.send_message(ong.phone, msg)
        else
          Rails.logger.info(
            "[WhatsApp][SIMULATION] admin_notify_available_quotations "\
            "quotation_id=#{quotation.id} customer_id=#{ong.id}"
          )
        end
      rescue => e
        Rails.logger.error("[WhatsApp] Falha ao notificar ONG (admin trigger) quotation_id=#{quotation.id}: #{e.message}")
      end
    end

    def purchase_order_created(purchase_order)
      SupplierMailer.purchase_order_created(purchase_order).deliver_later
      OngMailer.purchase_order_confirmation(purchase_order).deliver_later

      begin
        whatsapp = WhatsappNotifier.new
        if whatsapp.respond_to?(:enabled?) && whatsapp.enabled?
          po   = purchase_order
          q    = po.quotation
          ong  = po.customer
          supp = po.supplier

          msg_supplier = [
            "Novo Pedido de Compra ##{po.id} (cotação ##{q.id})",
            ("Vencimento: #{po.expiration_date.strftime('%d/%m/%Y')}" if po.expiration_date).to_s,
            "Valor total: R$ #{format('%.2f', po.total_value)}"
          ].reject(&:blank?).join(" | ")

          msg_ong = "Pedido de Compra ##{po.id} criado com sucesso (cotação ##{q.id})."

          whatsapp.send_message(supp.phone, msg_supplier)
          whatsapp.send_message(ong.phone,  msg_ong)
        else
          Rails.logger.info(
            "[WhatsApp][SIMULATION] purchase_order_created po_id=#{purchase_order.id} " \
            "supplier_id=#{purchase_order.supplier_id} customer_id=#{purchase_order.customer_id}"
          )
        end
      rescue => e
        Rails.logger.error("[WhatsApp] Falha ao notificar criação do PO ##{purchase_order.id}: #{e.message}")
      end
    end
  end
end

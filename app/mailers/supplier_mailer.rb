class SupplierMailer < ApplicationMailer
  def quotation_response_opened(quotation_response)
    @qr = quotation_response
    @supplier = @qr.supplier
    @quotation = @qr.quotation
    @ong = @quotation.customer

    mail(
      to: @supplier.email,
      subject: "Cotação disponível na Alimenz"
    )
  end

  def quotation_response_reminder(quotation_response, type)
    @qr = quotation_response
    @supplier = @qr.supplier
    @quotation = @qr.quotation
    @ong = @quotation.customer
    @type = type.to_sym
    @prazo = (@qr.expiration_date || @quotation.response_expiration_date)

    subjects = {
      after_2_days:   "Lembrete: responda a cotação #{@quotation.title}",
      one_day_before: "Cotação disponível até amanhã na Alimenz",
      on_due_day:     "Último dia para responder uma cotação na Alimenz"
    }

    mail(
      to: @supplier.email,
      subject: subjects[@type] || "Lembrete: cotação disponível na Alimenz"
    )
  end

  def purchase_order_created(purchase_order)
    @po        = purchase_order
    @supplier  = @po.supplier
    @ong       = @po.customer
    @quotation = @po.quotation
    @pdf_url   = secure_purchase_order_pdf_url(@po.signed_id)

    mail(
      to: @supplier.email,
      subject: "Pedido de compra na Alimenz"
    )
  end
end

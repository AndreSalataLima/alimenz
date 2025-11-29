class OngMailer < ApplicationMailer
  def quotation_created(quotation)
    @quotation = quotation
    @ong = quotation.customer
    mail(
      to: @ong.email,
      subject: "Cotação criada com sucesso: #{quotation.title}"
    )
  end

  def quotations_available(ong, quotation)
    @ong = ong
    @quotation = quotation
    mail(
      to: @ong.email,
      subject: "Nova cotação disponível na Alimenz"
    )
  end

  def purchase_order_confirmation(purchase_order)
    @po        = purchase_order
    @ong       = @po.customer
    @supplier  = @po.supplier
    @quotation = @po.quotation
    @pdf_url   = secure_purchase_order_pdf_url(@po.signed_id)

    mail(
      to: @ong.email,
      subject: "Confirmação do pedido de compra: #{@quotation.title}"
    )
  end
end

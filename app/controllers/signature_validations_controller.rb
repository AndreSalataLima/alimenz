class SignatureValidationsController < ApplicationController
  # skip_before_action :authenticate_user!

  def new
  end

  def create
    tracking = params[:signature_tracking_id].to_s.strip
    if tracking.blank?
      flash.now[:alert] = "Informe o código de rastreio."
      return render :new, status: :unprocessable_entity
    end

    if QuotationResponse.exists?(signature_tracking_id: tracking)
      redirect_to signature_validation_path(tracking)
    else
      flash.now[:alert] = "Código inválido. Tente novamente."
      render :new, status: :not_found
    end
  end

  def show
    @response = QuotationResponse.includes(:quotation, quotation_response_items: :quotation_item)
                                 .find_by(signature_tracking_id: params[:tracking_id])

    return redirect_to(new_signature_validation_path, alert: "Código inválido. Tente novamente.") unless @response

    # snapshots
    @customer_data = (@response.quotation.customer_snapshot || {}).symbolize_keys
    @supplier_data = (@response.supplier_snapshot || @response.supplier&.attributes || {}).symbolize_keys

    # agregados simples
    items = @response.quotation_response_items.select(&:available)
    @items_count = items.size
    @total_value = items.sum do |it|
      q = it.quotation_item.quantity
      (it.price || 0) * q
    end

    @signed_at   = @response.signed_at
    @signed_ip   = @response.signed_ip
    @tracking_id = @response.signature_tracking_id
    @title       = @response.quotation.title
  end

  def pdf
    response = QuotationResponse.find_by(signature_tracking_id: params[:tracking_id])
    return redirect_to(new_signature_validation_path, alert: "Código inválido. Tente novamente.") unless response

    pdf = PdfGeneratorService.new(response, use_signature: true).generate
    send_data pdf,
      filename: PdfGeneratorService.new(response, use_signature: true).filename,
      type: "application/pdf",
      disposition: "inline"
  end
end

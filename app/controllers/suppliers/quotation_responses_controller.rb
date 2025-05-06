module Suppliers
  class QuotationResponsesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_supplier
    before_action :set_and_authorize_quotation_response, only: [ :show, :edit, :update, :pdf, :upload_document, :confirm_upload, :sign ]

    def index
      @quotation_responses = policy_scope(QuotationResponse)
                             .includes(:quotation)
                             .order(created_at: :desc)
    end

    def show
      # Displays details of the quotation response
    end

    def edit
      if @quotation_response.quotation_response_items.empty?
        @quotation_response.quotation.quotation_items.each do |item|
          new_item = @quotation_response.quotation_response_items.build
          new_item.quotation_item = item
        end
      end

      @quotation_response.expiration_date ||= @quotation_response.quotation.expiration_date
    end


    def update
      use_pre_registered_signature = (params[:quotation_response][:use_pre_registered_signature] == "1")

      new_status = if use_pre_registered_signature && current_user.signature&.signature_image&.attached?
        "documento_enviado"
      else
        "aguardando_assinatura"
      end

      analysis_status_update = (new_status == "finalizado") ? { analysis_status: "pendente_de_analise" } : {}

      if @quotation_response.update(quotation_response_params.merge(status: new_status).merge(analysis_status_update))
        @quotation_response.reload

        if use_pre_registered_signature && current_user.signature&.signature_image&.attached?
          pdf_service = PdfGeneratorService.new(@quotation_response, use_pre_registered_signature: true)
          pdf_content = pdf_service.generate

          @quotation_response.signed_document.attach(
            io: StringIO.new(pdf_content),
            filename: pdf_service.filename,
            content_type: "application/pdf"
          )
        end

        respond_to do |format|
          format.html { redirect_to supplier_home_path, notice: "Cotação respondida com sucesso! Status: #{new_status.capitalize}" }
          format.turbo_stream { redirect_to supplier_home_path, notice: "Cotação respondida com sucesso! Status: #{new_status.capitalize}" }
        end
      else
        respond_to do |format|
          format.html { render :edit, status: :unprocessable_entity }
          format.turbo_stream { render :edit, status: :unprocessable_entity }
        end
      end
    end


    def confirm_upload
      uploaded_files = params[:quotation_response][:signed_documents]

      if uploaded_files.blank?
        redirect_to upload_document_supplier_quotation_response_path(@quotation_response), alert: "Nenhum documento foi selecionado." and return
      end

      unless uploaded_files.all? { |f| f.content_type =~ /\A(application\/pdf|image\/(png|jpeg|jpg))\z/ }
        redirect_to upload_document_supplier_quotation_response_path(@quotation_response), alert: "Apenas arquivos PDF ou imagens (JPG, PNG) são aceitos." and return
      end

      merged_pdf = PdfMergeService.merge_files(uploaded_files)

      pdf_service = PdfGeneratorService.new(@quotation_response)

      @quotation_response.signed_document.attach(
        io: merged_pdf,
        filename: pdf_service.filename,
        content_type: "application/pdf"
      )

      @quotation_response.update!(
        status: "documento_enviado",
        analysis_status: "pendente_de_analise"
      )

      redirect_to supplier_home_path, notice: "Proposta enviada com sucesso!"
    end



    def sign
      # Action to force PDF generation (for preview, for example)
      PdfGeneratorService.call(@quotation_response)
      redirect_to suppliers_quotation_response_path(@quotation_response), notice: "PDF generated successfully."
    end

    def upload_document
      # Logic to handle the manual upload of the signed document
    end

    def pdf
      pdf_service   = PdfGeneratorService.new(@quotation_response)
      pdf_content   = pdf_service.generate

      send_data pdf_content,
                filename: pdf_service.filename,
                type: "application/pdf",
                disposition: "inline"
    end



    def secure_pdf
      @quotation_response = QuotationResponse.find_signed!(params[:signed_id])
      authorize @quotation_response

      pdf_service = PdfGeneratorService.new(@quotation_response)
      pdf_content = pdf_service.generate

      send_data pdf_content,
                filename: pdf_service.filename,
                type: "application/pdf",
                disposition: "inline"
    end


    def secure_document
      @quotation_response = QuotationResponse.find_signed!(params[:signed_id])
      authorize @quotation_response

      if @quotation_response.signed_document.attached?
        redirect_to rails_blob_path(@quotation_response.signed_document, disposition: :inline)
      else
        redirect_to supplier_home_path, alert: "Documento não encontrado."
      end
    end

    private

    def set_and_authorize_quotation_response
      @quotation_response = policy_scope(QuotationResponse).find_by(id: params[:id])

      if @quotation_response.nil?
        redirect_to supplier_home_path, alert: "Cotação não encontrada ou acesso não autorizado."
      else
        authorize @quotation_response
      end
    end


    def quotation_response_params
      params.require(:quotation_response).permit(
        :expiration_date, :status, :use_pre_registered_signature, :signed_document,
        quotation_response_items_attributes: [ :id, :quotation_item_id, :price, :available, :_destroy ]
      )
    end

    def verify_supplier
      unless current_user.role.in?(%w[supplier admin])
        redirect_to root_path, alert: "Acesso negado."
      end
    end


  end
end

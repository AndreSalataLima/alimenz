module Suppliers
  class QuotationResponsesController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_supplier
    before_action :set_quotation_response, only: [ :show, :edit, :update, :pdf, :upload_document, :confirm_upload, :sign ]

    def index
      @quotation_responses = current_user.quotation_responses.includes(:quotation)
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
    end

    def update
      use_pre_registered_signature = (params[:quotation_response][:use_pre_registered_signature] == "1")

      new_status = if use_pre_registered_signature && current_user.signature&.signature_image&.attached?
        "finalizado"
      else
        "aguardando assinatura"
      end

      analysis_status_update = (new_status == "finalizado") ? { analysis_status: "pendente_de_analise" } : {}

      if @quotation_response.update(quotation_response_params.merge(status: new_status).merge(analysis_status_update))
        @quotation_response.reload

        if use_pre_registered_signature && current_user.signature&.signature_image&.attached?
          pdf_content = PdfGeneratorService.new(@quotation_response, use_pre_registered_signature: true).generate
          @quotation_response.signed_document.attach(
            io: StringIO.new(pdf_content),
            filename: "quotation_response_#{@quotation_response.id}.pdf",
            content_type: "application/pdf"
          )
        end

        redirect_to supplier_home_path, notice: "Quotation responded successfully! Status: #{new_status.capitalize}"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def confirm_upload
      @quotation_response = QuotationResponse.find(params[:id])

      if params[:quotation_response][:signed_documents].present?
        merged_pdf = PdfMergeService.merge_files(params[:quotation_response][:signed_documents])

        @quotation_response.signed_document.attach(
          io: merged_pdf,
          filename: "quotation_#{@quotation_response.id}.pdf",
          content_type: "application/pdf"
        )

        @quotation_response.update(status: "finalizado", analysis_status: "pendente_de_analise")

        redirect_to supplier_home_path, notice: "Quotation sent successfully!"
      else
        redirect_to upload_document_supplier_quotation_response_path(@quotation_response), alert: "No document selected."
      end
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
      @quotation_response = QuotationResponse.find(params[:id])
      pdf_content = PdfGeneratorService.new(@quotation_response).generate
      send_data pdf_content,
                filename: "quotation_response_#{@quotation_response.id}.pdf",
                type: "application/pdf",
                disposition: "inline"
    end

    private

    def set_quotation_response
      @quotation_response = QuotationResponse.find(params[:id])
    end

    def quotation_response_params
      params.require(:quotation_response).permit(
        :expiration_date, :status, :use_pre_registered_signature, :signed_document,
        quotation_response_items_attributes: [ :id, :quotation_item_id, :price, :available, :_destroy ]
      )
    end

    def verify_supplier
      redirect_to root_path, alert: "Access denied." unless current_user.role == "supplier"
    end
  end
end

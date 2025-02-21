# app/controllers/fornecedores/respostas_de_cotacao_controller.rb
module Fornecedores
  class RespostasDeCotacaoController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_fornecedor
    before_action :set_resposta, only: [:show, :edit, :update, :pdf, :upload_documento, :confirmar_upload]

    def index
      @respostas = current_usuario.respostas_de_cotacao.includes(:cotacao)
    end

    def show
      # Exibe detalhes da resposta
    end

    def edit
      if @resposta.resposta_de_cotacao_items.empty?
        @resposta.cotacao.itens_de_cotacao.each do |item|
          novo_item = @resposta.resposta_de_cotacao_items.build
          novo_item.item_de_cotacao = item
        end
      end
    end

    def update
      # Permitir que o fornecedor edite a cotação enquanto estiver "aguardando assinatura"
      if @resposta.status == "aguardando assinatura"
        if @resposta.update(resposta_de_cotacao_params)
          redirect_to fornecedor_home_path, notice: "Cotação atualizada com sucesso!"
        else
          render :edit, status: :unprocessable_entity
        end
        return # Encerra aqui para evitar sobrescrever o status
      end

      # Se estiver finalizando a cotação, verifica se há assinatura pré-cadastrada
      if current_usuario.assinaturas.any? && params[:resposta_de_cotacao][:usar_assinatura_pre_cadastrada] == "1"
        novo_status = "finalizado"
      else
        novo_status = "aguardando assinatura"
      end

      if @resposta.update(resposta_de_cotacao_params.merge(status: novo_status))
        redirect_to fornecedor_home_path, notice: "Cotação respondida com sucesso! Status: #{novo_status.capitalize}"
      else
        render :edit, status: :unprocessable_entity
      end
    end


    def confirmar_upload
      @resposta = RespostaDeCotacao.find(params[:id])

      if params[:resposta_de_cotacao][:documentos_assinados].present?
        merged_pdf = PdfMergeService.merge_files(params[:resposta_de_cotacao][:documentos_assinados])

        # Anexa o novo PDF corretamente usando StringIO
        @resposta.documento_assinado.attach(
          io: merged_pdf,
          filename: "cotacao_#{@resposta.id}.pdf",
          content_type: "application/pdf"
        )

        @resposta.update(status: "finalizado")
        redirect_to fornecedor_home_path, notice: "Cotação enviada com sucesso!"
      else
        redirect_to upload_documento_fornecedores_resposta_de_cotacao_path(@resposta), alert: "Nenhum documento selecionado."
      end
    end



    def assinar
      # Ação para forçar a geração do PDF (pré-visualização, por exemplo)
      PdfGeneratorService.call(@resposta)
      redirect_to fornecedores_resposta_de_cotacao_path(@resposta), notice: "PDF gerado com sucesso."
    end

    def upload_documento
      # Lógica para receber o upload do documento assinado manualmente
    end

    def pdf
      @resposta = RespostaDeCotacao.find(params[:id])
      pdf_content = PdfGeneratorService.new(@resposta).generate
      send_data pdf_content,
                filename: "resposta_cotacao_#{@resposta.id}.pdf",
                type: "application/pdf",
                disposition: "inline"  # 'inline' para exibir no browser ou 'attachment' para forçar download
    end

    private

    def set_resposta
      @resposta = RespostaDeCotacao.find(params[:id])
    end

    def resposta_de_cotacao_params
      params.require(:resposta_de_cotacao).permit(
        :data_validade, :status, :usar_assinatura_pre_cadastrada, :documento_assinado,
        resposta_de_cotacao_items_attributes: [:id, :item_de_cotacao_id, :preco, :disponivel, :_destroy]
      )
    end

    def verificar_fornecedor
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "fornecedor"
    end
  end
end

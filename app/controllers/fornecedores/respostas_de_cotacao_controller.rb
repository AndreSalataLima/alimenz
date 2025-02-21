# app/controllers/fornecedores/respostas_de_cotacao_controller.rb
module Fornecedores
  class RespostasDeCotacaoController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_fornecedor
    before_action :set_resposta, only: [:show, :edit, :update, :assinar, :upload_documento]

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
      # Força o status para "finalizado" independentemente do que vier do formulário
      if @resposta.update(resposta_de_cotacao_params.merge(status: "finalizado"))
        redirect_to fornecedor_home_path(@resposta), notice: "Cotação finalizada com sucesso! Agora visualize e baixe o PDF."
      else
        render :edit, status: :unprocessable_entity
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
        :data_validade, :status, :usar_assinatura_pre_cadastrada,
        resposta_de_cotacao_items_attributes: [:id, :item_de_cotacao_id, :preco, :disponivel, :_destroy]
      )
    end



    def verificar_fornecedor
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "fornecedor"
    end
  end
end

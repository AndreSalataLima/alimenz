module Admin
  class FornecedoresController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_admin
    before_action :set_fornecedor, only: [:show, :edit, :update]

    def index
      @fornecedores = Usuario.where(papel: "fornecedor")
    end

    def show
      # Exibe os detalhes do fornecedor, inclusive a assinatura (se houver)
    end

    def edit
      # Exibe formulário para editar os dados do fornecedor e fazer upload da assinatura
    end

    def update
      if @fornecedor.update(fornecedor_params)
        redirect_to admin_fornecedor_path(@fornecedor), notice: "Fornecedor atualizado com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_fornecedor
      @fornecedor = Usuario.find(params[:id])
    end

    def fornecedor_params
      params.require(:usuario).permit(:telefone, assinatura_attributes: [:id, :imagem_assinatura, :imagem_carimbo, :_destroy])
    end

    def verificar_admin
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "admin"
    end
  end
end

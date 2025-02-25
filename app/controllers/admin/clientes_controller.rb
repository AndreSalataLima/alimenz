module Admin
  class Admin::ClientesController < ApplicationController
    before_action :authenticate_usuario!
    before_action :verificar_admin
    before_action :set_cliente, only: [:show, :edit, :update]

    def index
      @clientes = Usuario.where(papel: "cliente")
    end

    def show
      # Exibe os detalhes do cliente, inclusive a assinatura (se houver)
    end

    def edit
      # Exibe formulário para editar os dados do cliente e fazer upload da assinatura
    end

    def update
      if @cliente.update(cliente_params)
        redirect_to admin_cliente_path(@cliente), notice: "cliente atualizado com sucesso!"
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_cliente
      @cliente = Usuario.find(params[:id])
    end

    def cliente_params
      params.require(:usuario).permit(:telefone, assinatura_attributes: [:imagem_assinatura])
    end

    def verificar_admin
      redirect_to root_path, alert: "Acesso negado." unless current_usuario.papel == "admin"
    end
  end
end

class Admin::UsuariosController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_admin
  before_action :set_usuario, only: [:show, :edit, :update, :destroy]

  def index
    @usuarios = Usuario.all
  end

  def show
  end

  def new
    @usuario = Usuario.new
  end

  def create
    @usuario = Usuario.new(usuario_params)
    if @usuario.save
      redirect_to admin_usuario_path(@usuario), notice: 'Usuário criado com sucesso.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @usuario.update(usuario_params)
      redirect_to admin_usuario_path(@usuario), notice: 'Usuário atualizado com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @usuario.destroy
    redirect_to admin_usuarios_path, notice: 'Usuário removido com sucesso.'
  end

  private

  def set_usuario
    @usuario = Usuario.find(params[:id])
  end

  def usuario_params
    params.require(:usuario).permit(
      :nome, :email, :papel, :cnpj, :responsavel, :endereco, :logo,
      :commission_percentage, :telefone, :password, :password_confirmation,
      assinatura_attributes: [:id, :imagem_assinatura, :imagem_carimbo, :_destroy],
      categoria_ids: []
    )
  end




  def verificar_admin
    unless current_usuario && current_usuario.papel == 'admin'
      redirect_to root_path, alert: 'Acesso negado.'
    end
  end
end

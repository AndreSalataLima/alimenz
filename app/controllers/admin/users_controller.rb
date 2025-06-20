class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :verify_admin
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.all
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # Atribuição explícita do role
    @user.role = params[:user][:role] if params[:user][:role].present?
    if @user.save
      redirect_to admin_customers_path, notice: "Usuário criado com sucesso."
    else
      render :new
    end
  end

  def edit
  end

  def update
    new_params = user_params.merge(role: params[:user][:role])

    # Remove valores vazios e atualiza categorias manualmente para evitar duplicações
    if params[:user][:category_ids]
      @user.category_ids = params[:user][:category_ids].reject(&:blank?)
    end

    # Faz o update com os demais atributos, exceto category_ids
    if @user.update(new_params.except(:category_ids))
      redirect_to admin_user_path(@user), notice: "User updated successfully."
    else
      Rails.logger.debug "ERROS: #{@user.errors.full_messages}"
      render :edit, status: :unprocessable_entity, formats: [:html]
    end

  end


  def destroy
    @user.destroy
    redirect_to admin_users_path, notice: "User removed successfully."
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    # Verificar se devo retirar o :role do params
    params.require(:user).permit(
      :name, :email, :cnpj, :responsible, :address, :logo, :phone, :password, :password_confirmation, :trade_name, :role,
      signature_attributes: [ :id, :signature_image, :stamp_image, :_destroy ],
      category_ids: []
    )
  end

  def verify_admin
    unless current_user && current_user.role == "admin"
      redirect_to root_path, alert: "Access denied."
    end
  end
end

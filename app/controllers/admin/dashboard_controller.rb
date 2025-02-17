class Admin::DashboardController < ApplicationController
  before_action :authenticate_usuario!
  before_action :verificar_admin

  def index
    # Aqui você pode colocar a lógica que quiser exibir no painel
  end

  def pending_verifications
    # Método já declarado na rota, caso necessário
  end

  private

  def verificar_admin
    unless current_usuario && current_usuario.papel == 'admin'
      redirect_to root_path, alert: "Acesso negado."
    end
  end
end

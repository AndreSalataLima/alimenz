class ApplicationController < ActionController::Base
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def after_sign_in_path_for(resource)
    case resource.papel
    when 'admin'
      admin_dashboard_index_path
    when 'fornecedor'
      # Redirecione para o painel do fornecedor
      #respostas_de_cotacao_index_path
      fornecedor_home_path
    when 'cliente'
      # Redirecione para o painel do cliente
      #cotacoes_index_path
      cliente_home_path
    else
      root_path
    end
  end

  # Configure parâmetros extras para o sign up (se necessário, mesmo que o registro público esteja desabilitado)
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: [:nome, :papel])
  end
end

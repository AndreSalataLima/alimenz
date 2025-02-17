class FornecedoresController < ApplicationController
  before_action :authenticate_usuario!

  def home
    # Aqui você pode adicionar lógica específica para o fornecedor
  end
end

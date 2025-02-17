class Usuarios::RegistrationsController < Devise::RegistrationsController
  protected

  # Permite que o usuário atualize seu perfil sem precisar informar a senha
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # Após a atualização, redireciona para a página de edição
  def after_update_path_for(resource)
    edit_usuario_registration_path
  end
end

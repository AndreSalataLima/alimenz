class Users::RegistrationsController < Devise::RegistrationsController
  protected

  # Allows the user to update their profile without providing the current password
  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  # After update, redirects to the edit page
  def after_update_path_for(resource)
    edit_user_registration_path
  end
end

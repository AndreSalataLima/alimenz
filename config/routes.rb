Rails.application.routes.draw do
  devise_for :usuarios, controllers: { registrations: 'usuarios/registrations' }


  # namespace :admin do
  #   get "usuarios/index"
  #   get "usuarios/new"
  #   get "usuarios/create"
  #   get "usuarios/edit"
  #   get "usuarios/update"
  #   get "usuarios/destroy"
  # end
  namespace :admin do
    resources :usuarios
    resources :dashboard, only: [:index]

    get 'pending_verifications', to: 'dashboard#pending_verifications'
  end


  # Páginas de "home" para fornecedor e cliente
  get 'fornecedor_home', to: 'fornecedores#home'
  get 'cliente_home', to: 'clientes#home'


  get "up" => "rails/health#show", as: :rails_health_check




  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: redirect("/usuarios/sign_in")

end

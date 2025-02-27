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
    resources :clientes, only: [:index, :show, :edit, :update]
    resources :fornecedores, only: [:index, :show, :edit, :update]
    resources :cotacoes, only: [:index, :show]
    resources :dashboard, only: [:index]

    resources :respostas_de_cotacao, only: [:index, :show] do
      member do
        patch :aprovar
        patch :reprovar
      end
    end

    get 'pending_verifications', to: 'dashboard#pending_verifications'
  end


  # Páginas de "home" para fornecedor e cliente
  get 'fornecedor_home', to: 'fornecedores#home'
  get 'cliente_home', to: 'clientes#home'

  resources :pedidos_de_compras, only: [:index, :show, :new, :create] do
    member do
      get :pdf, to: "pedidos_de_compras#pdf", as: :pdf
    end
  end

  resources :produtos do
    resources :produto_customizados, only: [:create]
  end

  resources :cotacoes, only: [:index, :new, :create, :show] do
    member do
      # Novo fluxo para gerar pedidos de compra
      get :selecionar_pedidos    # Passo 4: Exibe a tabela com itens (linhas) x fornecedores (colunas)
      post :resumo_pedidos        # Passo 5: Recebe os checkboxes e exibe os cards de resumo
      post :finalizar_pedidos     # Passo 7: Gera os Pedidos de Compra a partir dos pedidos confirmados
    
    end
  end

  namespace :fornecedores do
    resources :respostas_de_cotacao, only: [:index, :show, :edit, :update] do
      member do
        get "pdf", to: "respostas_de_cotacao#pdf"
        get "upload_documento", to: "respostas_de_cotacao#upload_documento"
        post "confirmar_upload", to: "respostas_de_cotacao#confirmar_upload"
      end
    end
  end



  get "up" => "rails/health#show", as: :rails_health_check




  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root to: redirect("/usuarios/sign_in")

end

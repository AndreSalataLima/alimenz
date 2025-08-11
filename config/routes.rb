Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  namespace :admin do
    namespace :commissions do
      get "commission_payments/create"
    end
    get "commissions/index"
    get "commissions/show"
    resources :users, only: [:new, :create, ]
    resources :customers, only: [ :index, :show, :edit, :update ]
    resources :suppliers, only: [ :index, :show, :edit, :update ]
    resources :dashboard, only: [ :index ]
    resources :categories, only: [:index, :new, :create, :edit, :update]
    resources :products

    resources :quotations, only: [ :index, :show ] do
      member do
        patch :encerrar_respostas
        patch :arquivar
        patch :concluir
      end
    end

    resources :quotation_responses, only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
    end

    resources :purchase_orders, only: [:index, :show] do
      member do
        patch :confirmar
        patch :desconsiderar
      end
    end

    resources :commissions, only: [:index, :show] do
      member do
        patch :mark_paid_full
        patch :unmark_paid_full
      end

      resources :commission_payments, module: :commissions, only: [:create, :edit, :update, :destroy]
    end


    # get 'pending_verifications', to: 'dashboard#pending_verifications'
  end

  # Home pages for supplier and customer
  get "supplier_home", to: "suppliers#home"
  get "customer_home", to: "customers#home"

  resources :purchase_orders, only: [ :index, :show, :new, :create ]


  resources :products do
    resources :customized_products, only: [ :create ]
  end

  resources :quotations, only: [ :index, :new, :create, :show, :edit, :update ] do
    member do
      # New flow to generate purchase orders
      get :select_orders        # Step 4: Displays the table with items (rows) x suppliers (columns)
      post :orders_summary      # Step 5: Receives the checkboxes and displays the summary cards
      post :finalize_orders     # Step 7: Generates the Purchase Orders from the confirmed orders
      patch :arquivar
    end
  end

  namespace :suppliers do
    resources :quotation_responses, only: [ :index, :show, :edit, :update ] do
      member do
        get "upload_document", to: "quotation_responses#upload_document"
        post "confirm_upload", to: "quotation_responses#confirm_upload"
        get :digital_signature_form
        post :submit_digital_signature
      end
    end
  end

  scope :validar do
    get  "/",                 to: "signature_validations#new",   as: :new_signature_validation
    post "/",                 to: "signature_validations#create",as: :signature_validations
    get  "/:tracking_id",     to: "signature_validations#show",  as: :signature_validation
    get  "/:tracking_id/pdf", to: "signature_validations#pdf",   as: :signature_validation_pdf
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "/suppliers/quotation_responses/secure/:signed_id/pdf", to: "suppliers/quotation_responses#secure_pdf", as: :secure_pdf_suppliers_quotation_response
  get "/suppliers/quotation_responses/secure/:signed_id/document", to: "suppliers/quotation_responses#secure_document", as: :secure_document_suppliers_quotation_response
  get "/purchase_orders/secure/:signed_id/pdf", to: "purchase_orders#secure_pdf", as: :secure_purchase_order_pdf


  # Defines the root path route ("/")
  root to: redirect("/users/sign_in")
end

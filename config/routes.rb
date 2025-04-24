Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  namespace :admin do
    resources :users, only: [:new, :create, ]
    resources :customers, only: [ :index, :show, :edit, :update ]
    resources :suppliers, only: [ :index, :show, :edit, :update ]
    resources :quotations, only: [ :index, :show ]
    resources :dashboard, only: [ :index ]
    resources :purchase_orders, only: [:index, :show]
    resources :categories, only: [:index, :new, :create, :edit, :update]
    resources :products


    resources :quotation_responses, only: [ :index, :show ] do
      member do
        patch :approve
        patch :reject
      end
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

  resources :quotations, only: [ :index, :new, :create, :show ] do
    member do
      # New flow to generate purchase orders
      get :select_orders        # Step 4: Displays the table with items (rows) x suppliers (columns)
      post :orders_summary      # Step 5: Receives the checkboxes and displays the summary cards
      post :finalize_orders     # Step 7: Generates the Purchase Orders from the confirmed orders
    end
  end

  namespace :suppliers do
    resources :quotation_responses, only: [ :index, :show, :edit, :update ] do
      member do
        get "upload_document", to: "quotation_responses#upload_document"
        post "confirm_upload", to: "quotation_responses#confirm_upload"
      end
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
  get "/suppliers/quotation_responses/secure/:signed_id/pdf", to: "suppliers/quotation_responses#secure_pdf", as: :secure_pdf_suppliers_quotation_response
  get "/suppliers/quotation_responses/secure/:signed_id/document", to: "suppliers/quotation_responses#secure_document", as: :secure_document_suppliers_quotation_response
  get "/purchase_orders/secure/:signed_id/pdf", to: "purchase_orders#secure_pdf", as: :secure_purchase_order_pdf


  # Defines the root path route ("/")
  root to: redirect("/users/sign_in")
end

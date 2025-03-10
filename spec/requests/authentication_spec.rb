require 'rails_helper'

RSpec.describe "Autenticação", type: :request do
  let(:admin)     { User.create!(name: "Admin", email: "admin@example.com", role: "admin", password: "123456") }
  let(:supplier)  { User.create!(name: "Fornecedor", email: "fornecedor@example.com", role: "supplier", password: "123456") }
  let(:customer)  { User.create!(name: "Cliente", email: "cliente@example.com", role: "customer", password: "123456") }

  it "redireciona o admin para o dashboard correto" do
    sign_in admin
    get root_path
    expect(response).to redirect_to(admin_dashboard_index_path)
  end

  it "redireciona o fornecedor para o painel de respostas" do
    sign_in supplier
    get root_path
    expect(response).to redirect_to(suppliers_quotation_responses_path)
  end

  it "redireciona o cliente para as cotações" do
    sign_in customer
    get root_path
    expect(response).to redirect_to(quotations_path)
  end
end

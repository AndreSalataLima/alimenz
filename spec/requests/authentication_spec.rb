# spec/requests/authentication_spec.rb
require 'rails_helper'

RSpec.describe "Autenticação", type: :request do
  let(:admin) { Usuario.create!(nome: "Admin", email: "admin@example.com", papel: "admin", password: "123456") }
  let(:fornecedor) { Usuario.create!(nome: "Fornecedor", email: "fornecedor@example.com", papel: "fornecedor", password: "123456") }
  let(:cliente) { Usuario.create!(nome: "Cliente", email: "cliente@example.com", papel: "cliente", password: "123456") }

  it "redireciona o admin para o dashboard correto" do
    sign_in admin
    get root_path
    expect(response).to redirect_to(admin_dashboard_index_path)
  end

  it "redireciona o fornecedor para o painel de respostas" do
    sign_in fornecedor
    get root_path
    expect(response).to redirect_to(respostas_de_cotacao_index_path)
  end

  it "redireciona o cliente para as cotações" do
    sign_in cliente
    get root_path
    expect(response).to redirect_to(cotacoes_index_path)
  end
end

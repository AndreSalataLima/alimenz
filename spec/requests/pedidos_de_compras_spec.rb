require 'rails_helper'

RSpec.describe "PedidosDeCompras", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/pedidos_de_compras/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/pedidos_de_compras/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/pedidos_de_compras/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/pedidos_de_compras/create"
      expect(response).to have_http_status(:success)
    end
  end

end

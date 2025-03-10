require 'rails_helper'

RSpec.describe "PurchaseOrders", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/purchase_orders/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/purchase_orders/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /new" do
    it "returns http success" do
      get "/purchase_orders/new"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /create" do
    it "returns http success" do
      get "/purchase_orders/create"
      expect(response).to have_http_status(:success)
    end
  end
end

require 'rails_helper'

RSpec.describe "Admin::Suppliers", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/suppliers/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/suppliers/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/suppliers/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/suppliers/update"
      expect(response).to have_http_status(:success)
    end
  end
end

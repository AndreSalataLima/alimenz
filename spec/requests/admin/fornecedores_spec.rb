require 'rails_helper'

RSpec.describe "Admin::Fornecedores", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/fornecedores/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/fornecedores/show"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /edit" do
    it "returns http success" do
      get "/admin/fornecedores/edit"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /update" do
    it "returns http success" do
      get "/admin/fornecedores/update"
      expect(response).to have_http_status(:success)
    end
  end

end

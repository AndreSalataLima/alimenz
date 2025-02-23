require 'rails_helper'

RSpec.describe "Admin::Cotacoes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/cotacoes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/cotacoes/show"
      expect(response).to have_http_status(:success)
    end
  end

end

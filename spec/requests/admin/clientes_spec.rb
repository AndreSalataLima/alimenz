require 'rails_helper'

RSpec.describe "Admin::Clientes", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/clientes/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/clientes/show"
      expect(response).to have_http_status(:success)
    end
  end

end

require 'rails_helper'

RSpec.describe "Admin::Quotations", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/quotations/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /show" do
    it "returns http success" do
      get "/admin/quotations/show"
      expect(response).to have_http_status(:success)
    end
  end
end

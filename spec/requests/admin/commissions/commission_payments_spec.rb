require 'rails_helper'

RSpec.describe "Admin::Commissions::CommissionPayments", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/admin/commissions/commission_payments/create"
      expect(response).to have_http_status(:success)
    end
  end

end

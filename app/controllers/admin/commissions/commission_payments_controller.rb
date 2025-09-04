module Admin
  module Commissions
    class CommissionPaymentsController < ApplicationController
      before_action :authenticate_user!
      before_action :verify_admin
      before_action :set_commission
      before_action :set_payment, only: [ :edit, :update, :destroy ]

      def create
        @commission_payment = @commission.commission_payments.new(commission_payment_params)

        if @commission_payment.save
          redirect_to admin_commission_path(@commission), notice: "Pagamento adicionado com sucesso."
        else
          @purchase_order = @commission.purchase_order
          @payments = @commission.commission_payments.order(payment_date: :asc)
          render "admin/commissions/show", status: :unprocessable_entity
        end
      end

      def edit
        @commission = Commission.find(params[:commission_id])
        @payment = CommissionPayment.find(params[:id])
      end

      def update
        if @commission_payment.update(commission_payment_params)
          redirect_to admin_commission_path(@commission), notice: "Pagamento atualizado com sucesso."
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def destroy
        @commission_payment.destroy
        redirect_to admin_commission_path(@commission), notice: "Pagamento excluído com sucesso."
      end

      private

      def set_commission
        @commission = Commission.find(params[:commission_id])
      end

      def set_payment
        @commission_payment = @commission.commission_payments.find(params[:id])
      end

      def commission_payment_params
        params.require(:commission_payment).permit(:payment_date, :amount)
      end

      def verify_admin
        redirect_to root_path, alert: "Acesso negado." unless current_user&.role == "admin"
      end
    end
  end
end

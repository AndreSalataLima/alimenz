module Admin
  class CommissionsController < ApplicationController
    before_action :authenticate_user!
    before_action :verify_admin
    before_action :set_commission, only: [:show, :mark_paid_full, :unmark_paid_full]

    def index
      @year_ref  = params[:year_ref].present? ? params[:year_ref].to_i : Date.current.year
      @month_ref = params[:month_ref].present? ? params[:month_ref].to_i : nil

      if @month_ref.present?
        start_date = Date.new(@year_ref, @month_ref, 1)
        end_date = start_date.end_of_month
      else
        start_date = Date.new(@year_ref, 1, 1)
        end_date = start_date.end_of_year
      end

      @purchase_orders = PurchaseOrder
        .where(created_at: start_date.beginning_of_day..end_date.end_of_day)
        .includes(:commission, :customer, :supplier, :quotation)
        .order(:created_at)

      @purchase_orders_abertas = @purchase_orders.select { |po| po.status == 'aberta' }.sort_by(&:id)
      @purchase_orders_confirmadas = @purchase_orders.select { |po| po.status == 'confirmada' }.sort_by(&:id)
      @purchase_orders_arquivadas = @purchase_orders.select { |po| po.status == 'arquivada' }.sort_by(&:id)

      @commissions = Commission.where(purchase_order_id: @purchase_orders.pluck(:id)).includes(purchase_order: :supplier)

      @supplier_commissions = @commissions.group_by { |c| c.purchase_order.supplier.name }
                                          .transform_values { |commissions| commissions.sum(&:total_commission) }


    end

    def show
      @purchase_order = @commission.purchase_order
      @payments = @commission.commission_payments.order(payment_date: :asc)
      @new_payment = CommissionPayment.new
    end

    def mark_paid_full
      paid_total = @commission.paid_total
      new_total_commission_param = params[:new_total_commission]

      if paid_total <= 0
        render json: { error: "Nenhum valor foi pago ainda." }, status: :unprocessable_entity
        return
      end

      Commission.transaction do
        if new_total_commission_param.present?
          new_total = BigDecimal(new_total_commission_param.to_s)
          @commission.update!(total_commission: new_total, paid_in_full: true)
        else
          @commission.update!(paid_in_full: true)
        end
      end

      render json: { success: true }, status: :ok
    end


    def unmark_paid_full
      @commission.update(paid_in_full: false)
      redirect_to admin_commission_path(@commission), notice: "Marca de pagamento integral removida."
    end

    private

    def set_commission
      @commission = Commission.find(params[:id])
    end

    def verify_admin
      redirect_to root_path, alert: "Acesso negado." unless current_user&.role == "admin"
    end
  end
end

class QuotationResponsePolicy < ApplicationPolicy
  def show?
    user.role == "admin" ||
      (user.role == "supplier" && record.supplier_id == user.id)
  end
  alias_method :pdf?, :show?

  def update?
    user.role == "admin" ||
      (user.role == "supplier" && record.supplier_id == user.id)
  end

  def edit?
    record.supplier_id == user.id
  end

  def secure_document?
    show?
  end

  def secure_pdf?
    show?
  end

  def upload_document?
    show?
  end

  def confirm_upload?
    user.role == "admin" ||
      (user.role == "supplier" &&
       record.supplier_id == user.id &&
       [ "aguardando_assinatura", "revisao_fornecedor" ].include?(record.status))
  end

  # 3) Scope para index
  class Scope < Scope
    def resolve
      return scope.all if user.role == "admin"

      if user.role == "supplier"
        scope.where(supplier_id: user.id)
      else
        # se você também quiser que clientes vejam suas próprias cotações:
        scope.joins(:quotation).where(quotations: { customer_id: user.id })
      end
    end
  end

  def digital_signature_form?
    user.role == "supplier" && record.supplier_id == user.id && record.status == "aguardando_assinatura revisao_fornecedor"
  end

  def submit_digital_signature?
    digital_signature_form?
  end
end

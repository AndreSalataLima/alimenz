class QuotationResponsePolicy < ApplicationPolicy
  # 1) Define quem pode ver um registro específico
  def show?
    user.role == 'admin' ||
      (user.role == 'supplier' && record.supplier_id == user.id)
  end
  alias_method :pdf?, :show?

  # 2) Define quem pode editar/atualizar
  def update?
    user.role == 'admin' ||
      (user.role == 'supplier' && record.supplier_id == user.id && record.status == 'pendente')
  end


  def secure_document?
    show?
  end

  def secure_pdf?
    show?
  end



  # 3) Scope para index
  class Scope < Scope
    def resolve
      return scope.all if user.role == 'admin'

      if user.role == 'supplier'
        scope.where(supplier_id: user.id)
      else
        # se você também quiser que clientes vejam suas próprias cotações:
        scope.joins(:quotation).where(quotations: { customer_id: user.id })
      end
    end
  end
end

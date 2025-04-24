class PurchaseOrderPolicy < ApplicationPolicy
  def show?
    user.role == 'admin' ||
      (user.role == 'supplier' && record.supplier_id == user.id) ||
      (user.role == 'customer' && record.customer_id == user.id)
  end
  alias_method :pdf?, :show?

  class Scope < Scope
    def resolve
      return scope.all if user.role == 'admin'

      if user.role == 'supplier'
        scope.where(supplier_id: user.id)
      else
        scope.where(customer_id: user.id)
      end
    end
  end
end

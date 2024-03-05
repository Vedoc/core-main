class ClientPolicy < ApplicationPolicy
  def show?
    user.business_owner?
  end
end

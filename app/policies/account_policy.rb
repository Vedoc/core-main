class AccountPolicy < ApplicationPolicy
  def update?
    !user.employee?
  end
end

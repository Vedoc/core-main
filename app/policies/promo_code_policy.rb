class PromoCodePolicy < ApplicationPolicy
  def create?
    !user.employee? && user.business_owner?
  end
end

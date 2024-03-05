class VehiclePolicy < ApplicationPolicy
  def index?
    user.client?
  end

  def create?
    user.client?
  end

  def update?
    user.client?
  end

  def destroy?
    user.client?
  end
end

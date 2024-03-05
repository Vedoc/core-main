class CarModelPolicy < ApplicationPolicy
  def index?
    user.client?
  end
end

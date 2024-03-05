class CarMakePolicy < ApplicationPolicy
  def index?
    user.client?
  end
end

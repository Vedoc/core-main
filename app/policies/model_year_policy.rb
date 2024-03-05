class ModelYearPolicy < ApplicationPolicy
  def index?
    user.client?
  end
end

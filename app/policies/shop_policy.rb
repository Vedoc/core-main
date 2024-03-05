class ShopPolicy < ApplicationPolicy
  def index?
    user.client?
  end

  def show?
    user.client?
  end
end

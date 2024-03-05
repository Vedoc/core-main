class OfferPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize( user, scope )
      @user  = user
      @scope = scope
    end

    def resolve
      # scope.where( shop: user.accountable ).not_accepted
      return user.accountable.offers.not_accepted if user.client?

      user.accountable.offers
    end
  end

  def create?
    user.business_owner?
  end

  def update?
    create?
  end

  def accept?
    user.client?
  end
end

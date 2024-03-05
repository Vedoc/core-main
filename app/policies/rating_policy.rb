class RatingPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize( user, scope )
      @user  = user
      @scope = scope
    end

    def resolve
      user.accountable.offers.accepted_only.where service_requests: { status: :done }
    end
  end

  def create?
    user.client?
  end
end

class ServiceRequestPolicy < ApplicationPolicy
  class Scope
    attr_reader :user, :scope

    def initialize( user, scope )
      @user  = user
      @scope = scope.includes :pictures, :vehicle, :offers
    end

    def resolve
      if user.client?
        scope.where vehicle: user.accountable.vehicles
      else
        scope.joins(
          'LEFT JOIN offers ON service_requests.id = offers.service_request_id ' \
          "AND offers.shop_id = #{ user.accountable.id }"
        ).where( category: user.accountable.categories ).pending.within_distance user.location
      end
    end
  end

  class ShowScope < Scope
    def resolve
      if user.client?
        scope.where vehicle: user.accountable.vehicles
      else
        scope.joins(
          'LEFT JOIN offers ON service_requests.id = offers.service_request_id ' \
          "AND offers.shop_id = #{ user.accountable.id }"
        ).where( category: user.accountable.categories ).within_distance user.location
      end
    end
  end

  def index?
    user.client? || user.business_owner?
  end

  def jobs?
    user.business_owner?
  end

  def create?
    user.client?
  end

  def show?
    user.client? || user.business_owner?
  end

  def pay?
    user.client?
  end

  def destroy?
    user.client?
  end
end

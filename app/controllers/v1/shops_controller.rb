module V1
  class ShopsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!
    before_action :set_current_account
    before_action :set_shop, only: :show

    def index
      @shops = Shop.approved.within_distance(
        OpenStruct.new( lat: params[ :lat ], lon: params[ :long ] )
      ).by_rating.where( 'LOWER(name) LIKE LOWER(?)', "%#{ params[ :name ] }%" )
    end

    def show; end

    private

    def authorize_account!
      authorize Shop.new
    end

    # To use in views
    def set_current_account
      @current_account = current_account
    end

    def set_shop
      @shop = Shop.approved.where( id: params[ :id ] )

      if current_account.accountable.location.present?
        @shop = @shop.nearest(
          current_account.accountable.location, :asc, 1
        )
      end

      @shop = @shop.first

      render_errors( errors: [ I18n.t( 'shop.errors.not_found' ) ], status: :not_found ) unless @shop
    end
  end
end

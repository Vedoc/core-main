module V1
  class RatingsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_rating!
    before_action :set_offer, only: :create

    def create
      @rating = current_account.accountable.ratings.build offer: @offer, score: rating_params[ :score ]

      render( :error, status: :unprocessable_entity ) unless @rating.save
    end

    private

    def rating_params
      params.require( :rating ).permit :score
    end

    def set_offer
      @offer = policy_scope( Rating ).find_by id: params[ :offer_id ]

      return if @offer

      render_errors( errors: [ I18n.t( 'offer.errors.not_found' ) ], status: :not_found )
    end

    def authorize_rating!
      authorize Rating.new
    end
  end
end

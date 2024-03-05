module V1
  class OffersController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_offer!
    before_action :set_offer, only: %i[accept update]

    def create
      @offer = current_account.accountable.offers.build offer_params

      render( :error, status: :unprocessable_entity ) unless @offer.save

      PushNotification::NewOfferJob.perform_later @offer.id
    end

    def update
      pictures_count = @offer.pictures.count

      return render( :error, status: :unprocessable_entity ) unless @offer.update( offer_update_params )

      PushNotification::NewOfferPhotosJob.perform_later( @offer.id ) if @offer.pictures.count > pictures_count
    end

    # rubocop:disable Rails/SkipsModelValidations
    def accept
      unless charge_params[ :direct_pay ] == true
        charge = StripePaymentsService.new(
          amount: charge_params[ :amount ],
          token: charge_params[ :token ],
          description: I18n.t( 'charge.offer_accepted' )
        ).call
      end

      @offer.update paid: charge_params[ :amount ], accepted: true

      # Clenup remainig offers
      @offer.service_request.offers.where.not( id: @offer.id ).destroy_all

      CleanupMessagesJob.perform_later @offer.id, @offer.service_request_id
      PushNotification::HireJob.perform_later @offer.id

      render json: { status: :success }
    rescue Stripe::AuthenticationError, Stripe::CardError, Stripe::InvalidRequestError => error
      render_errors errors: [ error.message ]
    ensure
      @offer.update_attribute( :accepted, false ) unless charge_params[ :direct_pay ] == true || charge&.paid
    end
    # rubocop:enable Rails/SkipsModelValidations

    private

    def offer_params
      params.require( :offer ).permit :service_request_id, :budget, :description
    end

    def charge_params
      return {} unless params[ :charge ] || params[ :charge ].is_a?( Hash )

      params.require( :charge ).permit :token, :amount, :direct_pay
    end

    def offer_update_params
      params.require( :offer ).permit :budget, :description, pictures_attributes: %i[id data _destroy]
    end

    def set_offer
      @offer = policy_scope( Offer ).find_by id: params[ :id ]

      return if @offer

      render_errors( errors: [ I18n.t( 'offer.errors.not_found' ) ], status: :not_found )
    end

    def authorize_offer!
      authorize Offer.new
    end
  end
end

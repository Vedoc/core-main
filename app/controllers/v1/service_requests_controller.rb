module V1
  class ServiceRequestsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!
    before_action :set_current_account
    before_action :set_service_request, only: %i[show destroy]
    before_action :set_service_request_to_pay, only: :pay

    def index
      @service_requests = policy_scope( ServiceRequest ).where(
        'LOWER(title) LIKE LOWER(?)', "%#{ params[ :title ] }%"
      )

      return if current_account.business_owner? || params[ :status ].blank?

      @service_requests = @service_requests.where( status: params[ :status ] )
    end

    def jobs
      @service_requests = current_account.accountable.service_requests.nearest( current_account.accountable.location ).where.not status: :pending
    end

    def show; end

    def create
      @service_request = ServiceRequest.new service_request_params

      if @service_request.save
        charge = StripePaymentsService.new(
          amount: charge_params[ :amount ],
          token: charge_params[ :token ],
          description: I18n.t( 'charge.new_service_request' )
        ).call

        PushNotification::NewServiceRequestJob.perform_later @service_request.id
      else
        render( :error, status: :unprocessable_entity )
      end
    rescue Stripe::AuthenticationError, Stripe::CardError, Stripe::InvalidRequestError => error
      render_errors errors: [ error.message ]
    ensure
      @service_request.destroy unless charge&.paid
    end

    def destroy
      return render json: { status: :success } if @service_request.destroy

      render_errors errors: [ I18n.t( 'service_request.errors.destroy' ) ]
    end

    def pay
      return render( :error, status: :unprocessable_entity ) unless @service_request.update( status: :done )

      AdminMailer.service_payment_notification( current_account ).deliver_later
    end

    private

    def authorize_account!
      authorize ServiceRequest.new
    end

    def service_request_params
      params.require( :service_request ).permit(
        :summary, :title, :vehicle_id, :evacuation, :repair_parts, :vin, :address,
        :category, :schedule_service, :radius, :mileage, :estimated_budget,
        pictures_attributes: %i[id data _destroy], location: %i[lat long]
      )
    end

    def charge_params
      return {} unless params[ :charge ] || params[ :charge ].is_a?( Hash )

      params.require( :charge ).permit :token, :amount
    end

    def set_service_request
      @service_request = policy_scope(
        ServiceRequest,
        policy_scope_class: ServiceRequestPolicy::ShowScope
      ).includes( offers: :shop ).find_by id: params[ :id ]

      return if @service_request

      render_errors( errors: [ I18n.t( 'service_request.errors.not_found' ) ], status: :not_found )
    end

    def set_service_request_to_pay
      @service_request = policy_scope( ServiceRequest ).in_repair.find_by id: params[ :id ]

      return if @service_request

      render_errors( errors: [ I18n.t( 'service_request.errors.not_found' ) ], status: :not_found )
    end

    # To use in views
    def set_current_account
      @current_account = current_account
    end
  end
end

module V1
  class VehiclesController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!
    before_action :set_vehicle, only: %i[update destroy]

    def index
      @vehicles = current_account.vehicles.with_client.ordered
    end

    def create
      @vehicle = current_account.vehicles.build(vehicle_params)
      
      if @vehicle.save
        render :create
      else
        render :error, status: :unprocessable_entity
      end
    end

    def update
      render( :error, status: :unprocessable_entity ) unless @vehicle.update( vehicle_params )
    end

    def destroy
      return render_errors errors: [ I18n.t( 'vehicle.errors.requests_exist' ) ] if @vehicle.service_requests.count.positive?

      return render json: { status: :success } if @vehicle.destroy

      render_errors errors: [ I18n.t( 'vehicle.errors.destroy' ) ]
    end

    private

    def authorize_account!
      authorize Vehicle.new
    end

    def vehicle_params
      params.require(:vehicle).permit(
        :make, 
        :model, 
        :year, 
        :category, 
        :photo
      ).tap do |whitelisted|
        whitelisted[:client_id] = current_account.accountable.id if current_account.client?
      end
    end

    def set_vehicle
      @vehicle = current_account.accountable.vehicles.find_by id: params[ :id ]

      return if @vehicle

      render_errors errors: [ I18n.t( 'vehicle.errors.not_found' ) ], status: :not_found
    end
  end
end

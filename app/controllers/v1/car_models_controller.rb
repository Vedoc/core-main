module V1
  class CarModelsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!

    def index
      @car_models = CarModel.where car_make_id: params[ :car_make_id ]
    end

    private

    def authorize_account!
      authorize CarModel.new
    end
  end
end

module V1
  class ModelYearsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!

    def index
      @model_years = ModelYear.where car_model_id: params[ :car_model_id ]
    end

    private

    def authorize_account!
      authorize ModelYear.new
    end
  end
end

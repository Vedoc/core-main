module V1
  class CarMakesController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!

    def index
      @car_makes = CarMake.joins( :car_category ).where 'car_categories.name = ?', params[ :category ]
    end

    private

    def authorize_account!
      authorize CarMake.new
    end
  end
end

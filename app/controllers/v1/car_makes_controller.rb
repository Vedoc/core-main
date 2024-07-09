# app/controllers/v1/car_makes_controller.rb
module V1
  class CarMakesController < ApplicationController
    include Swagger::Blocks

    before_action :authenticate_account!
    before_action :authorize_account!

    swagger_path '/car_makes' do
      operation :get do
        key :summary, 'List all car makes'
        key :description, 'Returns all car makes'
        key :operationId, 'listCarMakes'
        key :produces, ['application/json']
        key :tags, ['Car Makes']

        parameter name: :category do
          key :in, :query
          key :description, 'Category name (for example, car, truck)'
          key :required, false
          key :type, :string
        end

        response 200 do
          key :description, 'Car Make response'
          schema type: :array do
            items do
              key :'$ref', :CarMake
            end
          end
        end
        response :default do
          key :description, 'Unexpected error'
          schema do
            key :'$ref', :ErrorModel
          end
        end
      end
    end

    def index
      @car_makes = CarMake.joins(:car_category).where('car_categories.name = ?', params[:category])
      render json: @car_makes
    end

    private

    def authorize_account!
      authorize CarMake.new
    end
  end
end

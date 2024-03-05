module Docs
  module V1
    module CarMakes
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Car Make' do
          endpoint '/car_makes'
          group 'Car Details'
        end
      end

      # Params
      index_params = {
        category: {
          type: :string,
          required: :optional,
          description: "Category Name (for example, 'car', 'truck')",
          value: 'car'
        }
      }

      # Action Data
      document :index do
        action 'List Car Makes' do
          params index_params
        end
      end
    end
  end
end

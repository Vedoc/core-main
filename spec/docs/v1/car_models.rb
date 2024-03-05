module Docs
  module V1
    module CarModels
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Car Model' do
          endpoint '/car_models'
          group 'Car Details'
        end
      end

      # Action Data
      document :index do
        action 'List Car Models'
      end
    end
  end
end

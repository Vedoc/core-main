module Docs
  module V1
    module Shops
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Shop' do
          endpoint '/shops'
          group 'Shops'
        end
      end

      # Action Data
      document :show do
        action 'Show Shop'
      end

      index_params = {
        name: {
          type: :string,
          value: 'Test',
          description: 'Shop name'
        },
        lat: {
          type: :number,
          value: 123.123,
          description: 'Latitude'
        },
        long: {
          type: :number,
          value: 123.123,
          description: 'Longitude'
        }
      }

      document :index do
        action 'Index Shop' do
          params index_params
        end
      end
    end
  end
end

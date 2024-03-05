module Docs
  module V1
    module Vehicles
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Vehicle' do
          endpoint '/vehicles'
          group 'Vehicles'
        end
      end

      # Action Data
      document :index do
        action 'List vehicles'
      end

      document :create do
        action 'Create a vehicle'
      end

      document :update do
        action 'Update a vehicle'
      end

      document :destroy do
        action 'Destroy a vehicle'
      end
    end
  end
end

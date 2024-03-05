module Docs
  module V1
    module Devices
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Device' do
          endpoint '/devices'
          group 'Devices'
        end
      end

      # Action Data
      document :create do
        action 'Create/Update a device'
      end
    end
  end
end

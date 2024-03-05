module Docs
  module V1
    module Clients
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Client' do
          endpoint '/clients'
          group 'Clients'
        end
      end

      # Action Data
      document :show do
        action 'Show Client'
      end
    end
  end
end

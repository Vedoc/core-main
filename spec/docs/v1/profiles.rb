module Docs
  module V1
    module Profiles
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Profile' do
          endpoint '/profile'
          group 'Profile'
        end
      end

      # Action Data
      document :show do
        action 'Show a profile'
      end
    end
  end
end

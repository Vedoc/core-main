module Docs
  module V1
    module Sessions
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Session' do
          endpoint '/sign_in'
          group 'Sessions'
        end
      end

      # Action Data
      document :create do
        action 'Create a session'
      end

      document :destroy do
        action 'Destroy a session'
      end
    end
  end
end

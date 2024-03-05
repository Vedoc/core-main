module Docs
  module V1
    module Passwords
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Password' do
          endpoint '/password'
          group 'Passwords'
        end
      end

      # Action Data
      document :create do
        action 'Request a password reset'
      end
    end
  end
end

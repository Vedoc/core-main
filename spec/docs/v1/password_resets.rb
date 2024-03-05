module Docs
  module V1
    module PasswordResets
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Password Reset' do
          endpoint '/password_resets'
          group 'Passwords'
        end
      end

      # Action Data
      document :create do
        action 'Create a password reset'
      end
    end
  end
end

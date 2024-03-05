module Docs
  module V1
    module Settings
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Setting' do
          endpoint '/settings'
          group 'Settings'
        end
      end

      # Action Data
      document :index do
        action 'List Settings'
      end
    end
  end
end

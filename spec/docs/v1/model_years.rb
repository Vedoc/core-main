module Docs
  module V1
    module ModelYears
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Model Year' do
          endpoint '/model_years'
          group 'Car Details'
        end
      end

      # Action Data
      document :index do
        action 'List Model Years'
      end
    end
  end
end

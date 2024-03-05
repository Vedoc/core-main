module Docs
  module V1
    module Ratings
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Rating' do
          endpoint '/ratings'
          group 'Ratings'
        end
      end

      # Action Data
      document :create do
        action 'Create a rate for the offer'
      end
    end
  end
end

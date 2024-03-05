module Docs
  module V1
    module Offers
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Offer' do
          endpoint '/offers'
          group 'Offers'
        end
      end

      # Action Data
      document :create do
        action 'Create an offer'
      end

      document :update do
        action 'Update an offer'
      end

      document :accept do
        action 'Accept an offer'
      end
    end
  end
end

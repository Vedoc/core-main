module Docs
  module V1
    module PromoCodes
      extend Dox::DSL::Syntax

      # Common resource data
      document :api do
        resource 'Promo Code' do
          endpoint '/promo_codes'
          group 'Promo Codes'
        end
      end

      # Action Data
      document :create do
        action 'Create a promo code'
      end
    end
  end
end

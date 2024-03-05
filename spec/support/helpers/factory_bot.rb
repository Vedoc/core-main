module FactoryBot
  module Syntax
    module Methods
      def location_data
        { 'lat' => Faker::Address.latitude, 'long' => Faker::Address.longitude }
      end
    end
  end
end

FactoryBot.define do
  factory :vehicle do
    make { Faker::Vehicle.make }
    model { Faker::Vehicle.model }
    year { Faker::Vehicle.year }
    category { Faker::Vehicle.car_type }
    photo { nil }

    factory :vehicle_with_photo do
      photo { Rack::Test::UploadedFile.new( Rails.root.join( 'spec/support/assets/test.jpg' ), 'image/jpeg' ) }
    end
  end
end

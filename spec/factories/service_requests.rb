FactoryBot.define do
  factory :service_request do
    summary { Faker::Lorem.sentence }
    title { Faker::Lorem.sentence }
    schedule_service { Time.now.utc }
    evacuation { false }
    repair_parts { false }
    vin { Faker::Vehicle.vin }
    radius { Faker::Number.number 2 }
    mileage { Faker::Number.number 2 }
    estimated_budget { Faker::Number.decimal 2 }
    location { location_data }
    category { ServiceRequest.categories.values.sample }
    address { Faker::Address.full_address }
    vehicle { create :vehicle, client: create( :client ) }
    pictures_attributes { attributes_for_list :picture, 2 }
    status { ServiceRequest.categories.values.first }

    factory :service_request_with_fake_pictures do
      pictures_attributes { attributes_for_list :fake_picture, 2 }
    end
  end
end

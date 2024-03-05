FactoryBot.define do
  factory :client do
    name { Faker::Lorem.unique.word }
    location { location_data }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.unique.phone_number }
  end
end

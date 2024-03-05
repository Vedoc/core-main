FactoryBot.define do
  factory :offer do
    service_request_id { Faker::Number.number( 2 ) }
    shop_id { Faker::Number.number( 2 ) }
    budget { Faker::Number.decimal 2 }
    description { Faker::Lorem.sentence }
    accepted { false }
  end
end

FactoryBot.define do
  factory :promo_code do
    shop
    email { Faker::Internet.email }
  end
end

FactoryBot.define do
  factory :model_year do
    year { Faker::Number.unique.between( 1900, 2020 ) }
    car_model
  end
end

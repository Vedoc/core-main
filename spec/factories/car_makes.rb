FactoryBot.define do
  factory :car_make do
    sequence( :name ) { | n | "#{ Faker::Lorem.word }##{ n }" }
    car_category { CarCategory.find_or_create_by name: %w[car truck].sample }
  end
end

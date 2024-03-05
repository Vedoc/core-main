FactoryBot.define do
  factory :car_model do
    sequence( :name ) { | n | "#{ Faker::Lorem.word }##{ n }" }
    car_make
  end
end

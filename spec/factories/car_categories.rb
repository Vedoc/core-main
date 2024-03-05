FactoryBot.define do
  factory :car_category do
    sequence( :name ) { | n | "category_#{ n }" }
  end
end

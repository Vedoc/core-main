FactoryBot.define do
  factory :device do
    account
    platform { :android }
    device_id { Faker::Device.unique.serial }
    device_token { Faker::Device.serial }
  end
end

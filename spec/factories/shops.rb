FactoryBot.define do
  factory :shop do
    name { Faker::Lorem.unique.word }
    owner_name { Faker::Name.name }
    hours_of_operation { Faker::Lorem.word }
    techs_per_shift { Faker::Number.number 1 }
    lounge_area { Faker::Boolean.boolean }
    supervisor_permanently { Faker::Boolean.boolean }
    complimentary_inspection { Faker::Boolean.boolean }
    vehicle_warranties { Faker::Boolean.boolean }
    categories { Shop::CATEGORIES.values.sample( 2 ) }
    languages { [ Faker::Lorem.word ] }
    vehicle_diesel { Faker::Boolean.boolean }
    vehicle_electric { Faker::Boolean.boolean }
    certified { Faker::Boolean.boolean }
    tow_track { Faker::Boolean.boolean }
    location { location_data }
    address { Faker::Address.full_address }
    phone { Faker::PhoneNumber.unique.phone_number }
    pictures_attributes { attributes_for_list :picture, 3 }
    approved { true }
    additional_info { Faker::Lorem.sentence }
    avatar { nil }

    factory :unapproved_shop do
      approved { false }
    end

    factory :shop_with_avatar do
      avatar { Rack::Test::UploadedFile.new( Rails.root.join( 'spec/support/assets/test.jpg' ), 'image/jpeg' ) }
    end
  end
end

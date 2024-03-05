FactoryBot.define do
  FakeCharge = Struct.new :amount, :token

  factory :charge, class: FakeCharge do
    amount { Faker::Number.number( 2 ) }
    token { Faker::Commerce.promotion_code }
    direct_pay { false }
  end
end

FactoryBot.define do
  factory :account do
    email { Faker::Internet.unique.email }
    password { Faker::Internet.password }
    accountable { build( :client ) }

    factory :business_account do
      accountable { build( :shop ) }
    end

    factory :account_with_device do
      after( :create ) do | account |
        create :device, account: account
      end
    end
  end
end

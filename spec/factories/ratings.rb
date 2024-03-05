FactoryBot.define do
  factory :rating do
    score { Faker::Number.between( 1, 5 ) }

    after( :build ) do | rating |
      client = create( :account ).accountable
      service_request = create :service_request, vehicle: create( :vehicle, client: client )

      rating.offer = create :offer, accepted: true, shop: create( :shop ), service_request: service_request
      rating.client = client

      # rubocop:disable Rails/SkipsModelValidations
      service_request.update_attribute :status, :done
      # rubocop:enable Rails/SkipsModelValidations
    end
  end
end

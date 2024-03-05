require 'rails_helper'

RSpec.describe 'GET internal/recepient' do
  context 'when offer is found' do
    let!( :account ) { create :account }
    let!( :vehicle ) { create :vehicle_with_photo, client: account.accountable }
    let!( :service_request ) { create :service_request, vehicle: vehicle }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      @offer = create(
        :offer,
        shop: create( :shop_with_avatar ),
        service_request: service_request
      )
      @recepient = account.client? ? @offer.shop : @offer.client

      get '/internal/recepient', params: { offer_id: @offer.id }, headers: auth_headers
    end

    it 'returns success response status' do
      expect( response ).to have_http_status :ok
    end

    it 'returns the recepient data' do
      expect( json ).to eq(
        'recepient' => {
          'name' => @recepient.name,
          'avatar' => @recepient.avatar.url,
          'accountable_id' => @recepient.id,
          'accountable_type' => @recepient.class.name,
          'offer' => {
            'id' => @offer.id,
            'service_request_id' => @offer.service_request_id
          }
        }
      )
    end
  end

  context 'when offer is not found' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      get '/internal/recepient', params: { offer_id: 0 }, headers: auth_headers
    end

    it 'returns not found response status' do
      expect( response ).to have_http_status :not_found
    end

    it 'returns a not found error', :dox do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'recepient.errors.not_found' ) ]
      )
    end
  end

  it_behaves_like 'unauthenticated', :get, '/internal/recepient'
end

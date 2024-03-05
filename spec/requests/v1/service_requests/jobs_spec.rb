require 'rails_helper'

RSpec.describe 'GET v1/service_requests/jobs' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Jobs

  context 'when account is a client' do
    let!( :account ) { create :account }
    let!( :shop_account ) { create :business_account }
    let( :auth_headers ) { shop_account.create_new_auth_token }
    let!( :vehicle ) { create :vehicle_with_photo, client: account.accountable }

    context 'when service requests are present' do
      let!( :service_requests ) { create_list :service_request, 3, status: :pending, vehicle: vehicle }

      before do
        service_requests.each do | request |
          create( :offer, accepted: true, service_request: request, shop: shop_account.accountable )
        end

        @service_requests = shop_account.accountable.service_requests.nearest(
          shop_account.accountable.location
        ).where.not status: :pending

        get '/v1/service_requests/jobs', headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of jobs', :dox do
        expect( @service_requests.to_a.size ).to eq service_requests.count
        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => @service_requests.map do | request |
            service_request_list_response( request ).merge(
              'distance' => ( request.distance * 0.000621371 ).round( 2 ),
              'phone' => request.client.phone,
              'offer' => offer_response( request.offers.find_by( shop: shop_account.accountable ) )
            )
          end
        )
      end
    end

    context 'when service requests are not present' do
      let!( :service_requests ) { create_list :service_request, 2, status: :pending, vehicle: vehicle }

      before do
        service_requests.each do | request |
          create( :offer, accepted: false, service_request: request, shop: shop_account.accountable )
        end

        get '/v1/service_requests/jobs', headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty jobs array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => []
        )
      end
    end
  end

  context 'when account is not a business owner' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      get '/v1/service_requests/jobs', headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/service_requests/jobs'
end

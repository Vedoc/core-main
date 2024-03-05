require 'rails_helper'

RSpec.describe 'GET v1/service_requests' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :vehicle ) { create :vehicle_with_photo, client: account.accountable }

    context 'when service requests are present' do
      let!( :service_requests ) { create_list :service_request, 3, vehicle: vehicle }

      before { get '/v1/service_requests', headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of clients service requests', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => service_requests.map do | request |
            service_request_list_response( request )
          end
        )
      end
    end

    context 'when service requests are not present' do
      before { get '/v1/service_requests', params: { title: 'foobar' }, headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty service requests array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => []
        )
      end
    end
  end

  context 'when account is a business owner' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when service requests are present' do
      let!( :service_requests ) do
        create_list(
          :service_request, 3,
          category: account.accountable.categories.first,
          location: {
            'lat' => account.location.lat,
            'long' => ( account.location.lon + 0.01 )
          }
        )
      end

      before do
        @service_requests = ServiceRequest.where( category: account.accountable.categories.first )
                                          .within_distance account.location
        @offer = create( :offer, service_request: @service_requests.last, shop: account.accountable )

        get '/v1/service_requests', headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of shops service requests', :dox do
        expect( @service_requests.present? ).to eq true

        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => @service_requests.map do | request |
            service_request_list_response( request ).merge(
              'distance' => ( request.distance * 0.000621371 ).round( 2 ),
              'phone' => request.client.phone
            )
          end
        )
      end
    end

    context 'when service requests are not present' do
      before { get '/v1/service_requests', params: { address: 'foobar' }, headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty service requests array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_requests' => []
        )
      end
    end
  end

  it_behaves_like 'unauthenticated', :get, '/v1/service_requests'
end

require 'rails_helper'

RSpec.describe 'GET v1/service_request/:id' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Show

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :vehicle ) { create :vehicle_with_photo, client: account.accountable }

    context 'when service requests are present' do
      let!( :service_request ) { create :service_request, vehicle: vehicle }

      before do
        offer = create :offer, shop: create( :shop_with_avatar ), service_request: service_request
        create :offer, shop: create( :shop_with_avatar ), service_request: service_request

        create_list :picture, 2, imageable: offer

        get "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns a clients service request data', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_request' => service_request_response( service_request ).merge(
            'offers' => Offer.all.map { | offer | offer_client_response offer }
          )
        )
      end
    end

    context 'when service request does not belong to the client' do
      let!( :another_account ) { create :account }
      let!( :another_request ) do
        create :service_request, vehicle: create( :vehicle, client: another_account.accountable )
      end

      before { get "/v1/service_requests/#{ another_request.id }", headers: auth_headers }

      it 'returns not found response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error' do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'service_request.errors.not_found' ) ]
        )
      end
    end
  end

  context 'when account is a business owner' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when service request is present' do
      let!( :service_request ) do
        create(
          :service_request,
          category: account.accountable.categories.first,
          location: {
            'lat' => account.location.lat,
            'long' => ( account.location.lon + 0.01 )
          }
        )
      end

      let!( :offer ) do
        create :offer, shop: account.accountable, service_request: service_request
      end

      before do
        @service_request = ServiceRequest.where( category: account.accountable.categories.first )
                                         .within_distance( account.location )
                                         .find_by id: service_request.id

        get "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns a business owners service request data', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'service_request' => service_request_response( @service_request ).merge(
            'distance' => ( @service_request.distance * 0.000621371 ).round( 2 ),
            'phone' => @service_request.client.phone,
            'offer' => offer_response( offer )
          )
        )
      end
    end

    context 'when service request is not in the area' do
      let!( :service_request ) do
        create(
          :service_request,
          category: account.accountable.categories.first,
          location: {
            'lat' => account.location.lat,
            'long' => ( account.location.lon + 10 )
          }
        )
      end

      before do
        get "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns not found response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error' do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'service_request.errors.not_found' ) ]
        )
      end
    end
  end

  context 'when service requests are not present' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/service_requests/0', headers: auth_headers }

    it 'returns not found response status' do
      expect( response ).to have_http_status :not_found
    end

    it 'returns a not found error', :dox do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'service_request.errors.not_found' ) ]
      )
    end
  end

  it_behaves_like 'unauthenticated', :get, '/v1/service_requests/0'
end

require 'rails_helper'

RSpec.describe 'GET v1/vehicles' do
  include Docs::V1::Vehicles::Api
  include Docs::V1::Vehicles::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when vehicles are present' do
      let!( :vehicles ) { create_list :vehicle_with_photo, 3, client: account.accountable }

      before { get '/v1/vehicles', headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of clients vehicles', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'vehicles' => account.vehicles.map { | vehicle | vehicle_response( vehicle ) }
        )
      end
    end

    context 'when vehicles are not present' do
      before { get '/v1/vehicles', headers: auth_headers }

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty vehicles array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'vehicles' => []
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/vehicles', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/vehicles'
end

require 'rails_helper'

RSpec.describe 'POST v1/vehicles' do
  include Docs::V1::Vehicles::Api
  include Docs::V1::Vehicles::Create

  context 'when account is a client' do
    context 'when vehicle params are valid' do
      let!( :account ) { create :account }
      let( :auth_headers ) { account.create_new_auth_token }
      let( :vehicle_attrs ) { attributes_for :vehicle }

      before :each, with_before: true do
        post_json '/v1/vehicles', params: { vehicle: vehicle_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'success',
          'vehicle' => vehicle_response( Vehicle.last )
        )
      end

      it 'creates vehicle record' do
        expect { post_json '/v1/vehicles', params: { vehicle: vehicle_attrs }, headers: auth_headers }
          .to change { Vehicle.count }.by 1
      end
    end

    context 'when vehicle params are invalid' do
      let!( :account ) { create :account }
      let( :auth_headers ) { account.create_new_auth_token }
      let( :vehicle_attrs ) { attributes_for :vehicle, model: nil }

      before :each, with_before: true do
        post_json '/v1/vehicles', params: { vehicle: vehicle_attrs }, headers: auth_headers
      end

      it 'returns unprocessable entity response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns vehicle errors messages', :with_before, :dox do
        vehicle = account.vehicles.build vehicle_attrs
        vehicle.save

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( vehicle ),
          'vehicle' => vehicle_response( vehicle )
        )
      end

      it 'creates no vehicle records' do
        expect do
          post_json '/v1/vehicles', params: { vehicle: vehicle_attrs }, headers: auth_headers
        end.to_not( change { Vehicle.count } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :vehicle_attrs ) { attributes_for :vehicle }

    before do
      post_json '/v1/vehicles', params: { vehicle: vehicle_attrs }, headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/vehicles'
end

require 'rails_helper'

RSpec.describe 'DELETE v1/vehicles/:id' do
  include Docs::V1::Vehicles::Api
  include Docs::V1::Vehicles::Destroy

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :vehicle ) { create :vehicle, client: account.accountable }

    context 'when vehicle exists' do
      before :each, with_before: true do
        delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns success message', :with_before, :dox do
        expect( json ).to eq 'status' => 'success'
      end

      it 'removes a vehicle record' do
        expect { delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers }
          .to change { Vehicle.count }.from( 1 ).to 0
      end
    end

    context 'when vehicle does not exist' do
      let!( :other_account ) { create :account }
      let!( :vehicle ) { create :vehicle, client: other_account.accountable }

      before :each, with_before: true do
        delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers
      end

      it 'returns not found response status', :with_before do
        expect( response ).to have_http_status :not_found
      end

      it 'returns not found error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'vehicle.errors.not_found' ) ]
        )
      end

      it 'does not destroy any vehicle' do
        expect { delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers }
          .to_not( change { Vehicle.count } )
      end
    end

    context 'when vehicle cannot be destroyed' do
      before do
        allow_any_instance_of( Vehicle ).to receive( :destroy ).and_return false
      end

      before :each, with_before: true do
        delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers
      end

      it 'returns unprocessable response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns a cannot be destroyed message', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'vehicle.errors.destroy' ) ]
        )
      end

      it 'does not remove a vehicle  record' do
        expect { delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers }
          .to_not( change { Vehicle.count } )
      end
    end

    context 'when vehicle have requests' do
      before do
        create :service_request, vehicle: vehicle
      end

      before :each, with_before: true do
        delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers
      end

      it 'returns unprocessable response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns a service requests exist error message', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'vehicle.errors.requests_exist' ) ]
        )
      end

      it 'does not remove a vehicle  record' do
        expect { delete "/v1/vehicles/#{ vehicle.id }", headers: auth_headers }
          .to_not( change { Vehicle.count } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      delete '/v1/vehicles/0', headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :delete, '/v1/vehicles/0'
end

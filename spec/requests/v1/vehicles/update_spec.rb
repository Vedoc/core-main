require 'rails_helper'

RSpec.describe 'PUT v1/vehicles/:id' do
  include Docs::V1::Vehicles::Api
  include Docs::V1::Vehicles::Update

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when vehicles exists' do
      let( :make ) { 'test' }
      let( :photo_url ) { Faker::Internet.url }
      let!( :vehicle ) { create :vehicle, make: make, client: account.accountable }

      context 'when vehicle params are valid' do
        let( :vehicle_attrs ) { attributes_for :vehicle, photo: 'UploadedFile' }

        before :each, with_before: true do
          allow_any_instance_of( Vehicle ).to receive_message_chain( :photo, :url ).and_return photo_url

          put_json "/v1/vehicles/#{ vehicle.id }", params: { vehicle: vehicle_attrs }, headers: auth_headers
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

        it 'changes attribute values' do
          expect do
            photo = build :picture

            put_json "/v1/vehicles/#{ vehicle.id }",
                     params: { vehicle: vehicle_attrs.merge( photo: photo.data ) },
                     headers: auth_headers
            vehicle.reload
          end.to change { vehicle.make }.from( make ).to vehicle_attrs[ :make ]
        end
      end

      context 'when vehicle params are invalid' do
        let( :vehicle_attrs ) { attributes_for :vehicle, make: nil, photo: 'UploadedFile' }

        before do
          allow_any_instance_of( Vehicle ).to receive_message_chain( :photo, :url ).and_return photo_url

          put_json "/v1/vehicles/#{ vehicle.id }", params: { vehicle: vehicle_attrs }, headers: auth_headers
        end

        it 'returns unprocessable entity response status' do
          expect( response ).to have_http_status :unprocessable_entity
        end

        it 'returns vehicle errors messages', :dox do
          vehicle.update vehicle_attrs

          expect( json ).to eq(
            'status' => 'error',
            'vehicle' => vehicle_response( vehicle ),
            'errors' => resource_errors( vehicle )
          )
        end
      end
    end

    context 'when vehicle does not exist' do
      let!( :other_account ) { create :account }
      let!( :vehicle ) { create :vehicle, client: other_account.accountable }
      let( :vehicle_attrs ) { attributes_for( :vehicle ).except :photo }

      before :each, with_before: true do
        put_json "/v1/vehicles/#{ vehicle.id }", headers: auth_headers, params: { vehicle: vehicle_attrs }
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
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :vehicle_attrs ) { attributes_for( :vehicle ).except :photo }

    before do
      put_json '/v1/vehicles/0', headers: auth_headers, params: { vehicle: vehicle_attrs }
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :put_json, '/v1/vehicles/0'
end

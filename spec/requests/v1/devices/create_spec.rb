require 'rails_helper'

RSpec.describe 'POST v1/devices' do
  include Docs::V1::Devices::Api
  include Docs::V1::Devices::Create

  context 'when device params are valid' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :device_attrs ) { attributes_for( :device ).except :account }

    context 'when device params are valid' do
      before :each, with_before: true do
        post_json '/v1/devices', params: { device: device_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'success',
          'device' => device_response( Device.last )
        )
      end

      it 'creates device record' do
        expect do
          post_json '/v1/devices', params: { device: device_attrs }, headers: auth_headers
        end.to change { Device.count }.from( 0 ).to 1
      end
    end

    context 'when device already exist' do
      let!( :device ) { account.devices.create device_attrs }
      let( :new_token ) { '12345678' }

      before :each, with_before: true do
        post_json '/v1/devices', params: {
          device: device_attrs.merge( device_token: new_token )
        }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before do
        expect( json ).to eq(
          'status' => 'success',
          'device' => device_response( Device.last )
        )
      end

      it 'changes device token' do
        expect do
          post_json '/v1/devices', params: {
            device: device_attrs.merge( device_token: new_token )
          }, headers: auth_headers

          device.reload
        end.to change { device.device_token }.from( device_attrs[ :device_token ] ).to new_token
      end
    end

    context 'when device params are invalid' do
      let( :device_attrs ) { attributes_for( :device, device_id: nil ).except :account }

      before :each, with_before: true do
        post_json '/v1/devices', params: { device: device_attrs }, headers: auth_headers
      end

      it 'returns unprocessable entity response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns device error messages', :with_before, :dox do
        device = account.devices.create device_attrs

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( device )
        )
      end

      it 'creates no vehicle records' do
        expect do
          post_json '/v1/devices', params: { device: device_attrs }, headers: auth_headers
        end.to_not( change { Device.count } )
      end
    end
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/devices'
end

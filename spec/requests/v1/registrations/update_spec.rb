require 'rails_helper'

RSpec.describe 'PUT v1/auth' do
  include Docs::V1::Registrations::Api
  include Docs::V1::Registrations::Update

  context 'when user is signed in' do
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when client account' do
      let!( :account ) { create :account }
      let( :new_attrs ) { { name: 'New Name', phone: '123456789' } }
      let!( :vehicles ) { create_list :vehicle_with_photo, 2, client: account.accountable }

      before :each, with_before: true do
        put_json '/v1/auth', params: { client: new_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns client account data', :with_before, :dox do
        account.reload

        expect( json ).to eq(
          'status' => 'success',
          'account' => {
            'email' => account.email,
            'client' => client_response( account.accountable ),
            'employee' => false
          }
        )
      end

      it 'changes account attributes' do
        expect do
          put_json '/v1/auth', params: { client: new_attrs }, headers: auth_headers

          account.reload
        end.to change { account.accountable.name }.to new_attrs[ :name ]
      end
    end

    context 'when shop account' do
      let!( :account ) { create :business_account }
      let( :picture ) { Picture.last }
      let( :new_attrs ) do
        {
          name: 'New Shop Name',
          lounge_area: !account.accountable.lounge_area,
          pictures_attributes: {
            '0' => { 'id' => picture.id, '_destroy' => true },
            '1' => attributes_for( :fake_picture )
          }
        }
      end

      before :each, with_before: true do
        allow_any_instance_of( Picture ).to receive( :valid? ).and_return true
        allow_any_instance_of( Picture ).to receive_message_chain( :data, :url ).and_return Faker::Internet.url

        put_json '/v1/auth', params: { shop: new_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns shop account data', :with_before, :dox do
        account.reload

        expect( json ).to eq(
          'status' => 'success',
          'account' => {
            'email' => account.email,
            'shop' => shop_response( account.accountable ),
            'employee' => false
          }
        )
      end

      it 'changes account attributes' do
        expect do
          put '/v1/auth', params: {
            shop: new_attrs.merge(
              pictures_attributes: {
                '0' => { 'id' => picture.id, '_destroy' => true },
                '1' => attributes_for( :picture )
              }
            )
          }, headers: auth_headers

          account.reload
        end.to change { account.accountable.name }.to new_attrs[ :name ]
      end
    end
  end

  context 'when account is employee' do
    let!( :account ) { create :business_account, employee: true }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      put_json '/v1/auth', headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :put_json, '/v1/auth'
end

require 'rails_helper'

RSpec.describe 'POST v1/auth' do
  include Docs::V1::Registrations::Api
  include Docs::V1::Registrations::Create

  describe 'with valid registration data' do
    let( :account_attrs ) do
      attributes_for( :account ).except( :accountable ).merge(
        device: attributes_for( :device ).except( :account )
      )
    end

    context 'when client registration' do
      before :each, with_before: true do
        post_json '/v1/auth', params: account_attrs
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns client account data', :with_before, :dox do
        account = Account.last

        expect( json ).to eq(
          'status' => 'success',
          'account' => {
            'email' => account.email,
            'client' => client_response( account.accountable ),
            'employee' => false
          },
          'auth' => {
            'access-token' => response.headers[ 'access-token' ],
            'client' => response.headers[ 'client' ],
            'token-type' => response.headers[ 'token-type' ],
            'uid' => response.headers[ 'uid' ]
          }
        )
      end

      it 'creates an account and client records' do
        expect do
          post_json '/v1/auth', params: account_attrs.merge(
            'client' => attributes_for( :client )
          )
        end.to change { Account.clients.count }.from( 0 ).to( 1 ).and(
          change { Client.all.count }.from( 0 ).to( 1 )
        ).and( change { Device.count }.from( 0 ).to( 1 ) )
      end
    end

    context 'when business owner registration' do
      before :each, with_before: true do
        allow_any_instance_of( Shop ).to receive( :pictures ).and_return build_list( :picture, 3 )
        allow_any_instance_of( Picture ).to receive( :valid? ).and_return true

        post_json '/v1/auth', params: account_attrs.merge(
          'shop' => attributes_for(
            :shop, pictures_attributes: attributes_for_list( :fake_picture, 3 )
          ).except( :approved )
        )
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns business owner success message', :with_before, :dox do
        expect( response.headers[ 'access-token' ] ).to eq nil
        expect( json ).to eq 'status' => 'success'
      end

      it 'creates an account and shop records' do
        expect do
          post '/v1/auth', params: account_attrs.merge(
            'shop' => attributes_for( :shop )
          )
        end.to change { Account.business_owners.count }.from( 0 ).to( 1 ).and(
          change { Shop.all.count }.from( 0 ).to( 1 ).and(
            change { Picture.all.count }.from( 0 ).to( 3 )
          ).and( change { Device.count }.from( 0 ).to( 1 ) )
        )
      end
    end
  end

  describe 'with invalid registration data' do
    let( :account_attrs ) { attributes_for( :account, email: '' ).except :accountable }
    let( :client_attrs ) { attributes_for :client }

    before :each, with_before: true do
      post_json '/v1/auth', params: account_attrs.merge(
        'client' => client_attrs
      )
    end

    it 'returns unprocessable response status', :with_before do
      expect( response ).to have_http_status :unprocessable_entity
    end

    it 'returns errors messages', :dox, :with_before do
      account = Account.new account_attrs
      account.accountable = Client.new client_attrs
      account.save

      expect( json ).to eq(
        'status' => 'error',
        'account' => {
          'email' => account.email,
          'client' => client_response( account.accountable ),
          'employee' => false
        },
        'errors' => resource_errors( account )
      )
    end
  end
end

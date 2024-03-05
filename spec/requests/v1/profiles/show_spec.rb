require 'rails_helper'

RSpec.describe 'GET v1/profile' do
  include Docs::V1::Profiles::Api
  include Docs::V1::Profiles::Show

  context 'when account was logged in' do
    context 'when client account' do
      let!( :account ) { create :account }
      let!( :vehicles ) { create_list :vehicle, 2, client: account.accountable }
      let( :auth_headers ) { account.create_new_auth_token }

      before { get '/v1/profile', headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns client account info', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'account' => {
            'email' => account.email,
            'client' => client_response( account.accountable )
          }
        )
      end
    end

    context 'when business owner account' do
      let!( :account ) { create :account, accountable: build( :shop ) }
      let( :auth_headers ) { account.create_new_auth_token }

      before { get '/v1/profile', headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns business owner account info', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'account' => {
            'email' => account.email,
            'shop' => shop_response( account.accountable )
          }
        )
      end
    end
  end

  it_behaves_like 'unauthenticated', :get, '/v1/profile'
end

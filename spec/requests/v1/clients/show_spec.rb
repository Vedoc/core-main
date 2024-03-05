require 'rails_helper'

RSpec.describe 'GET v1/clients/:id' do
  include Docs::V1::Clients::Api
  include Docs::V1::Clients::Show

  context 'when account is a business owner' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :client_account ) { create :account }

    context 'when client is present' do
      before do
        create_list :vehicle, 2, client: client_account.accountable

        get "/v1/clients/#{ client_account.accountable.id }", headers: auth_headers
      end

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns client data', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'client' => client_response( client_account.accountable )
        )
      end
    end

    context 'when client is not present' do
      before { get '/v1/clients/0', headers: auth_headers }

      it 'returns not found response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error', :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'client.errors.not_found' ) ]
        )
      end
    end
  end

  context 'when account is not a business owner' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/clients/0', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/clients/0'
end

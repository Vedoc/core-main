require 'rails_helper'

RSpec.describe 'DELETE v1/auth/sign_out' do
  include Docs::V1::Sessions::Api
  include Docs::V1::Sessions::Destroy

  context 'when account was logged in' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      delete '/v1/auth/sign_out', headers: auth_headers, params: {
        device_id: 'foobar123', platform: 'ios'
      }
    end

    it 'returns success response status' do
      expect( response ).to have_http_status :ok
    end

    it 'returns success status', :dox do
      expect( json ).to eq 'status' => 'success'
    end
  end

  context 'when account was not logged in' do
    before do
      delete '/v1/auth/sign_out'
    end

    it 'returns not found response status' do
      expect( response ).to have_http_status :not_found
    end

    it 'returns an error message', :dox do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'devise_token_auth.sessions.user_not_found' ) ]
      )
    end
  end
end

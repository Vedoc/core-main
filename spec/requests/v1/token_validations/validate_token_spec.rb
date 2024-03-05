require 'rails_helper'

RSpec.describe 'GET v1/auth/validate_token' do
  describe 'with valid auth credentials' do
    let!( :account ) { create :account }
    let( :auth_tokens ) { account.create_new_auth_token }

    before do
      get '/v1/auth/validate_token', params: auth_tokens
    end

    it 'returns success response status' do
      expect( response ).to have_http_status :ok
    end

    it 'returns account data' do
      expect( json ).to eq(
        'status' => 'success',
        'account' => {
          'id' => account.id,
          'name' => account.name,
          'avatar' => account.accountable.avatar.url,
          'accountable_type' => account.accountable_type,
          'accountable_id' => account.accountable_id
        }
      )
    end
  end

  describe 'with invalid auth credentials' do
    before do
      get '/v1/auth/validate_token', params: {
        'access-token' => '12345678',
        'client' => '123456',
        'uid' => 'foo@bar.com'
      }
    end

    it 'returns unauthrorized response status' do
      expect( response ).to have_http_status :unauthorized
    end

    it 'returns an errors message' do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'devise_token_auth.token_validations.invalid' ) ]
      )
    end
  end
end

require 'rails_helper'

RSpec.describe 'POST v1/auth/password_resets' do
  include Docs::V1::PasswordResets::Api
  include Docs::V1::PasswordResets::Create

  let( :password ) { Faker::Internet.password 8 }

  describe 'with valid token' do
    let!( :account ) { create :account, password: password }
    let!( :token ) { account.send_reset_password_instructions }

    before do
      post_json '/v1/auth/password_resets', params: {
        token: token,
        email: account.email,
        password: password
      }
    end

    it 'returns success response status' do
      expect( response ).to have_http_status :ok
    end

    it 'returns a success message', :dox do
      expect( json ).to eq(
        'status' => 'success',
        'message' => I18n.t( 'password_reset.success' )
      )
    end
  end

  describe 'with invalid token' do
    context 'when user with token not found' do
      let!( :account ) { create :account, password: password }

      before do
        post_json '/v1/auth/password_resets', params: {
          token: 'invalid_token',
          email: account.email,
          password: password
        }
      end

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found message', :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'password_reset.errors.not_found' ) ]
        )
      end
    end

    context 'when password invalid' do
      let!( :account ) { create :account, password: password }
      let!( :token ) { account.send_reset_password_instructions }
      let( :invalid_password ) { '123' }

      before do
        post_json '/v1/auth/password_resets', params: {
          token: token,
          email: account.email,
          password: '123'
        }
      end

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns an invalid password message', :dox do
        account.update password: invalid_password

        expect( json ).to eq(
          'status' => 'error',
          'errors' => account.errors.full_messages
        )
      end
    end
  end
end

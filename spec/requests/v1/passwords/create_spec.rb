require 'rails_helper'

RSpec.describe 'POST v1/auth/passwords' do
  include Docs::V1::Passwords::Api
  include Docs::V1::Passwords::Create

  describe 'with existing email' do
    let!( :account ) { create :account }

    before :each, with_before: true do
      post_json '/v1/auth/password', params: { email: account.email }
    end

    it 'returns success response status', :with_before do
      expect( response ).to have_http_status :ok
    end

    it 'returns client account info', :with_before, :dox do
      expect( json ).to eq(
        'status' => 'success',
        'password_reset_duration' => Setting.password_reset_duration,
        'message' => I18n.t( 'devise_token_auth.passwords.sended', email: account.email )
      )
    end

    it 'sends an email' do
      expect { post_json( '/v1/auth/password', params: { email: account.email } ) }
        .to change { ActionMailer::Base.deliveries.count }.by 1
    end
  end

  describe 'with invalid email' do
    let( :email ) { 'invalid@mail.com' }

    before do
      post_json '/v1/auth/password', params: { email: email }
    end

    it 'returns unauthorized response status' do
      expect( response ).to have_http_status :not_found
    end

    it 'returns a not found message', :dox do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'devise_token_auth.passwords.user_not_found', email: email ) ]
      )
    end
  end
end

require 'rails_helper'

RSpec.describe 'POST v1/auth/sign_in' do
  include Docs::V1::Sessions::Api
  include Docs::V1::Sessions::Create

  let( :password ) { Faker::Internet.password 8 }

  describe 'with valid credentials' do
    context 'when client account' do
      let!( :account ) { create :account, password: password }

      before :each, with_before: true do
        post_json '/v1/auth/sign_in', params: {
          email: account.email,
          password: password
        }.merge( device: attributes_for( :device ).except( :account ) )
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns client account info', :with_before, :dox do
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

      it 'creates a device record' do
        expect do
          post_json '/v1/auth/sign_in', params: {
            email: account.email,
            password: password
          }.merge( device: attributes_for( :device ).except( :account ) )
        end.to change { Device.count }.by( 1 )
      end
    end

    context 'when business owner account' do
      context 'when approved' do
        let!( :account ) { create :account, password: password, accountable: build( :shop ) }

        before do
          post_json '/v1/auth/sign_in', params: {
            email: account.email,
            password: password
          }.merge( device: attributes_for( :device ).except( :account ) )
        end

        it 'returns success response status', :with_before do
          expect( response ).to have_http_status :ok
        end

        it 'returns business owner account info', :with_before, :dox do
          expect( json ).to eq(
            'status' => 'success',
            'account' => {
              'email' => account.email,
              'shop' => shop_response( account.accountable ),
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

        it 'creates a device record' do
          expect do
            post_json '/v1/auth/sign_in', params: {
              email: account.email,
              password: password
            }.merge( device: attributes_for( :device ).except( :account ) )
          end.to change { Device.count }.by( 1 )
        end
      end

      context 'when unapproved' do
        let!( :account ) { create :account, password: password, accountable: build( :unapproved_shop ) }

        before do
          post_json '/v1/auth/sign_in', params: {
            email: account.email,
            password: password
          }
        end

        it 'returns unauthenticated response status' do
          expect( response ).to have_http_status :unauthorized
        end

        it 'returns unapproved account error', :dox do
          expect( json ).to eq(
            'status' => 'error',
            'errors' => [ I18n.t( 'devise_token_auth.sessions.not_confirmed' ) ]
          )
        end
      end
    end
  end

  describe 'with invalid credentials' do
    context 'when email is invalid' do
      before do
        post_json '/v1/auth/sign_in', params: {
          email: 'invalid@mail.com',
          password: password
        }
      end

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :unauthorized
      end

      it 'returns errors messages', :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'devise_token_auth.sessions.bad_credentials' ) ]
        )
      end
    end
  end
end

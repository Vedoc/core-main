require 'rails_helper'

RSpec.describe 'POST v1/auth' do
  include Docs::V1::Registrations::Api
  include Docs::V1::Registrations::Create

  describe 'with valid promo code' do
    let( :account_attrs ) do
      attributes_for( :account ).except( :accountable ).merge(
        device: attributes_for( :device ).except( :account )
      )
    end
    let!( :host_account ) { create :business_account }
    let!( :promo_code ) { create :promo_code, shop: host_account.accountable }

    before :each, with_before: true do
      post_json '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
    end

    it 'returns success response status', :with_before do
      expect( response ).to have_http_status :ok
    end

    it 'returns data of invited account', :with_before, :dox do
      account = Account.last

      expect( json ).to eq(
        'status' => 'success',
        'account' => {
          'email' => account.email,
          'shop' => shop_response( host_account.accountable ),
          'employee' => true
        },
        'auth' => {
          'access-token' => response.headers[ 'access-token' ],
          'client' => response.headers[ 'client' ],
          'token-type' => response.headers[ 'token-type' ],
          'uid' => response.headers[ 'uid' ]
        }
      )
    end

    it 'sets promo code activation date', :with_before do
      promo_code.reload

      expect( promo_code.activated_at.present? ).to eq true
    end

    it 'creates an account record' do
      expect do
        post '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
      end.to change { Account.business_owners.count }.by( 1 ).and(
        change { Device.count }.from( 0 ).to( 1 )
      )
    end

    it 'does not create a shop record' do
      expect do
        post '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
      end.to_not( change { Shop.count } )
    end
  end

  describe 'with invalid promo code' do
    let( :account_attrs ) { attributes_for( :account ).except :accountable }

    before :each, with_before: true do
      post_json '/v1/auth', params: account_attrs.merge( 'promo_code' => 'invalid promo code' )
    end

    it 'returns unprocessable response status', :with_before do
      expect( response ).to have_http_status :unprocessable_entity
    end

    it 'returns promo code not found error', :with_before, :dox do
      expect( json ).to eq(
        'status' => 'error',
        'account' => {
          'email' => account_attrs[ :email ],
          'employee' => false
        },
        'errors' => [
          {
            'key' => 'promo_code',
            'messages' => [ 'Promocode not found' ]
          }
        ]
      )
    end

    it 'creates no account records' do
      expect do
        post '/v1/auth', params: account_attrs.merge( 'promo_code' => 'invalid promo code' )
      end.to_not( change { Account.business_owners.count } )
    end

    it 'creates no device records' do
      expect do
        post '/v1/auth', params: account_attrs.merge( 'promo_code' => 'invalid promo code' )
      end.to_not( change { Device.count } )
    end
  end

  describe 'with expired promo code' do
    let( :account_attrs ) { attributes_for( :account ).except :accountable }
    let!( :host_account ) { create :business_account }
    let!( :promo_code ) { create :promo_code, shop: host_account.accountable }

    before :each, with_before: true do
      Setting.promo_code_duration = 0

      post_json '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
    end

    it 'returns unprocessable response status', :with_before do
      expect( response ).to have_http_status :unprocessable_entity
    end

    it 'returns promo code has expired error', :with_before, :dox do
      expect( json ).to eq(
        'status' => 'error',
        'account' => {
          'email' => account_attrs[ :email ],
          'employee' => false
        },
        'errors' => [
          {
            'key' => 'promo_code',
            'messages' => [ 'Promocode has expired' ]
          }
        ]
      )
    end

    it 'does not set promo code activation date', :with_before do
      promo_code.reload

      expect( promo_code.activated_at.present? ).to eq false
    end

    it 'creates no account records' do
      expect do
        Setting.promo_code_duration = 0

        post '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
      end.to_not( change { Account.business_owners.count } )
    end

    it 'creates no device records' do
      expect do
        Setting.promo_code_duration = 0

        post '/v1/auth', params: account_attrs.merge( 'promo_code' => promo_code.set_code_token )
      end.to_not( change { Device.count } )
    end
  end
end

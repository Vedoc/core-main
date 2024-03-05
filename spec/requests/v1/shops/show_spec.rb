require 'rails_helper'

RSpec.describe 'GET v1/shops/:id' do
  include Docs::V1::Shops::Api
  include Docs::V1::Shops::Show

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :shop_account ) { create :business_account }

    context 'when shop is present' do
      before do
        avatar = build :picture
        shop_account.accountable.update avatar: avatar.data

        # To include distance field
        @shop = Shop.approved.where( id: shop_account.accountable.id ).nearest(
          account.accountable.location, :asc, 1
        ).first

        get "/v1/shops/#{ shop_account.accountable.id }", headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns shop data', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'shop' => shop_response( @shop ).merge(
            'distance' => account.accountable.location ? ( @shop.distance * 0.000621371 ).round( 2 ) : nil
          )
        )
      end
    end

    context 'when shop is not present' do
      before { get '/v1/shops/0', headers: auth_headers }

      it 'returns not found response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error', :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'shop.errors.not_found' ) ]
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/shops/0', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/shops/0'
end

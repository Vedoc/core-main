require 'rails_helper'

RSpec.describe 'GET v1/shops' do
  include Docs::V1::Shops::Api
  include Docs::V1::Shops::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when shops found' do
      let!( :shop_account ) { create :business_account }

      before do
        avatar = build :picture
        shop_account.accountable.update avatar: avatar.data, location: account.accountable.pretty_location
        params = {
          name: shop_account.name[ 0..1 ],
          lat: account.location.lat,
          long: account.location.lon + 0.01
        }

        @shops = Shop.where( 'LOWER(name) LIKE LOWER(?)', "%#{ params[ :name ] }%" )
                     .within_distance OpenStruct.new( lat: params[ :lat ], lon: params[ :long ] )

        get '/v1/shops', params: params, headers: auth_headers
      end

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns shops data', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'shops' => @shops.order( average_rating: :desc ).map do | shop |
            {
              'id' => shop.id,
              'name' => shop.name,
              'phone' => shop.phone,
              'address' => shop.address,
              'distance' => ( shop.distance * 0.000621371 ).round( 2 ),
              'location' => shop.pretty_location,
              'avatar' => shop.avatar.url,
              'average_rating' => shop.average_rating.to_f
            }
          end
        )
      end
    end

    context 'when shops not found' do
      let!( :shop_account ) { create :business_account }

      before { get '/v1/shops', headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty shops collection', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'shops' => []
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/shops', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/shops'
end

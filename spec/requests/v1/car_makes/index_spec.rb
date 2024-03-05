require 'rails_helper'

RSpec.describe 'GET v1/car_makes' do
  include Docs::V1::CarMakes::Api
  include Docs::V1::CarMakes::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :category ) { create :car_category }

    context 'when car makes are present' do
      let!( :car_makes ) { create_list :car_make, 5, car_category: category }

      before { get '/v1/car_makes', params: { category: category.name }, headers: auth_headers }

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of car makes', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'car_makes' => car_makes.map do | make |
            {
              'id' => make.id,
              'name' => make.name
            }
          end
        )
      end
    end

    context 'when car makes are not present' do
      before { get '/v1/car_makes', params: { category: category.name }, headers: auth_headers }

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty car makes array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'car_makes' => []
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/car_makes', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/car_makes'
end

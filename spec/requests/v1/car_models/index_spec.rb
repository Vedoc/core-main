require 'rails_helper'

RSpec.describe 'GET v1/car_models' do
  include Docs::V1::CarModels::Api
  include Docs::V1::CarModels::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :car_make ) { create :car_make }
    let!( :different_models ) { create_list :car_model, 2 }

    context 'when car models are present' do
      let!( :car_models ) { create_list :car_model, 3, car_make: car_make }

      before { get '/v1/car_models', params: { car_make_id: car_make.id }, headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of car models', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'car_models' => car_models.map do | car_model |
            {
              'id' => car_model.id,
              'name' => car_model.name
            }
          end
        )
      end
    end

    context 'when car models are not present' do
      before { get '/v1/car_models', params: { car_make_id: car_make.id }, headers: auth_headers }

      it 'returns success response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty car models array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'car_models' => []
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/car_models', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/car_models'
end

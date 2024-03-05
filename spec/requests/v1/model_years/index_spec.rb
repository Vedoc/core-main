require 'rails_helper'

RSpec.describe 'GET v1/model_years' do
  include Docs::V1::ModelYears::Api
  include Docs::V1::ModelYears::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :car_make ) { create :car_make }
    let!( :car_model ) { create :car_model, car_make: car_make }
    let!( :different_years ) { create_list :model_year, 2 }

    context 'when model years are present' do
      let!( :model_years ) { create_list :model_year, 3, car_model: car_model }

      before { get '/v1/model_years', params: { car_model_id: car_model.id }, headers: auth_headers }

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns list of model years', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'model_years' => model_years.map do | model_year |
            {
              'id' => model_year.id,
              'year' => model_year.year
            }
          end
        )
      end
    end

    context 'when model years are not present' do
      before { get '/v1/model_years', params: { car_make_id: car_make.id }, headers: auth_headers }

      it 'returns unauthorized response status' do
        expect( response ).to have_http_status :ok
      end

      it 'returns an empty model years array', :dox do
        expect( json ).to eq(
          'status' => 'success',
          'model_years' => []
        )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/model_years', headers: auth_headers }

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :get, '/v1/model_years'
end

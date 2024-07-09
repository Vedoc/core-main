# spec/requests/v1/car_makes/index_spec.rb
require 'swagger_helper'

RSpec.describe 'CarMakes API', type: :request do
  path '/v1/car_makes' do
    get 'List Car Makes' do
      tags 'Car Makes'
      produces 'application/json'
      parameter name: :category, in: :query, type: :string, description: 'Category Name'

      response '200', 'car makes found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 car_makes: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     }
                   }
                 }
               },
               required: ['status', 'car_makes']

        let(:account) { create(:account) }
        let(:auth_headers) { account.create_new_auth_token }
        let(:category) { create(:car_category) }
        let(:car_makes) { create_list(:car_make, 5, car_category: category) }

        before { get '/v1/car_makes', params: { category: category.name }, headers: auth_headers }

        run_test! do
          expect(response).to have_http_status(:ok)
          expect(json['car_makes'].size).to eq(5)
        end
      end

      response '204', 'no car makes found' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 car_makes: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     }
                   }
                 }
               },
               required: ['status', 'car_makes']

        let(:account) { create(:account) }
        let(:auth_headers) { account.create_new_auth_token }
        let(:category) { create(:car_category) }

        before do
          CarMake.destroy_all
          get '/v1/car_makes', params: { category: category.name }, headers: auth_headers
        end

        run_test! do
          expect(response).to have_http_status(:no_content)
          expect(json['car_makes']).to be_empty
        end
      end

      response '401', 'unauthorized' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 car_makes: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     }
                   }
                 }
               },
               required: ['status', 'car_makes']

        let(:account) { create(:business_account) }
        let(:auth_headers) { account.create_new_auth_token }

        before { get '/v1/car_makes', headers: auth_headers }

        run_test! do
          expect(response).to have_http_status(:unauthorized)
        end
      end

      response '403', 'forbidden' do
        schema type: :object,
               properties: {
                 status: { type: :string },
                 car_makes: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string }
                     }
                   }
                 }
               },
               required: ['status', 'car_makes']

        let(:account) { create(:unauthorized_account) }
        let(:auth_headers) { account.create_new_auth_token }

        before { get '/v1/car_makes', headers: auth_headers }

        run_test! do
          expect(response).to have_http_status(:forbidden)
        end
      end
    end
  end
end

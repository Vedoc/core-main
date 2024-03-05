require 'rails_helper'

RSpec.describe 'POST v1/offers' do
  include Docs::V1::Offers::Api
  include Docs::V1::Offers::Create

  context 'when account is a business owner' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    context 'when offer params are valid' do
      let!( :offer_attrs ) do
        vehicle = create :vehicle, client: create( :account ).accountable
        service_request = create :service_request, vehicle: vehicle

        attributes_for( :offer, service_request_id: service_request.id ).except :shop_id
      end

      before :each, with_before: true do
        post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'success',
          'offer' => offer_response( Offer.last )
        )
      end

      it 'creates offer record' do
        expect { post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers }
          .to change { Offer.count }.by 1
      end

      it 'performs push notifications job' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers
        end.to have_enqueued_job PushNotification::NewOfferJob
      end
    end

    context 'when offer params are invalid' do
      let( :offer_attrs ) { attributes_for( :offer ).except :shop_id }

      before :each, with_before: true do
        post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers
      end

      it 'returns unprocessable entity response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns offer errors messages', :with_before, :dox do
        offer = account.accountable.offers.build offer_attrs
        offer.save

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( offer )
        )
      end

      it 'creates no vehicle records' do
        expect do
          post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers
        end.to_not( change { Offer.count } )
      end
    end
  end

  context 'when account is not a business owner' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :offer_attrs ) { attributes_for( :offer ).except :shop_id }

    before do
      post_json '/v1/offers', params: { offer: offer_attrs }, headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/offers'
end

require 'rails_helper'

RSpec.describe 'PUT v1/offers/:id' do
  include Docs::V1::Offers::Api
  include Docs::V1::Offers::Update

  context 'when account is a business owner' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :offer ) do
      vehicle = create :vehicle, client: create( :account ).accountable
      service_request = create :service_request, vehicle: vehicle, status: :in_repair

      create :offer, service_request: service_request, shop: account.accountable
    end

    context 'when offer params are valid' do
      let( :offer_attrs ) do
        attributes_for( :offer ).slice( :budget, :description ).merge(
          pictures_attributes: attributes_for_list( :fake_picture, 2 )
        )
      end

      before :each, with_before: true do
        fake_pictures_for Offer

        put_json "/v1/offers/#{ offer.id }", params: { offer: offer_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        offer.reload

        expect( json ).to eq(
          'status' => 'success',
          'offer' => offer_response( offer )
        )
      end

      it 'updates offer record' do
        expect do
          put "/v1/offers/#{ offer.id }", params: {
            offer: offer_attrs.merge( pictures_attributes: attributes_for_list( :picture, 2 ) )
          }, headers: auth_headers

          offer.reload
        end.to change { offer.description }.and( change { offer.budget } ).and(
          change { offer.pictures.count }.from( 0 ).to( 2 )
        )
      end

      it 'performs push notifications job' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          put "/v1/offers/#{ offer.id }", params: {
            offer: offer_attrs.merge( pictures_attributes: attributes_for_list( :picture, 2 ) )
          }, headers: auth_headers
        end.to have_enqueued_job( PushNotification::NewOfferPhotosJob ).with offer.id
      end
    end

    context 'when offer params are invalid' do
      let( :offer_attrs ) do
        attributes_for( :offer, budget: -1 ).slice( :budget, :description )
      end

      before :each, with_before: true do
        put_json "/v1/offers/#{ offer.id }", params: { offer: offer_attrs }, headers: auth_headers
      end

      it 'returns unprocessable entity response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns offer errors messages', :with_before, :dox do
        offer.update offer_attrs

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( offer )
        )
      end

      it 'does not update offer record' do
        expect do
          put_json "/v1/offers/#{ offer.id }", params: { offer: offer_attrs }, headers: auth_headers

          offer.reload
        end.to_not( change { offer.budget } )
      end
    end

    context 'when offer not found' do
      let( :new_auth_headers ) { create( :business_account ).create_new_auth_token }
      let( :offer_attrs ) do
        attributes_for( :offer, budget: -1 ).slice( :budget, :description )
      end

      before :each do
        put_json "/v1/offers/#{ offer.id }", params: { offer: offer_attrs }, headers: new_auth_headers
      end

      it 'returns not found response status' do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error message', :dox do
        offer.update offer_attrs

        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'offer.errors.not_found' ) ]
        )
      end
    end
  end

  context 'when account is not a business owner' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :offer_attrs ) { attributes_for( :offer ).except :shop_id }

    before do
      put_json '/v1/offers/1', params: { offer: offer_attrs.slice( :budget, :description ) },
                               headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :put, '/v1/offers/1'
end

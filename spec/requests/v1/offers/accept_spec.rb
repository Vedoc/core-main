require 'rails_helper'

RSpec.describe 'POST v1/offers/:id/accept' do
  include Docs::V1::Offers::Api
  include Docs::V1::Offers::Accept

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :charge_attrs ) { attributes_for :charge }

    before do
      vehicle = create :vehicle, client: account.accountable
      service_request = create :service_request, vehicle: vehicle

      create :offer, service_request_id: service_request.id, shop: create( :shop )
      @offer = create :offer, service_request_id: service_request.id, shop: create( :shop )
    end

    context 'when offer is found' do
      before do
        allow_any_instance_of( StripePaymentsService ).to receive( :call ).and_return OpenStruct.new( paid: true )
      end

      before :each, with_before: true do
        post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq 'status' => 'success'
      end

      it 'changes accepted field' do
        expect do
          post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers

          @offer.reload
        end.to change { @offer.accepted }.from( false ).to( true ).and change {
          @offer.service_request.status
        }.from( 'pending' ).to 'in_repair'
      end

      it 'removes remaining offers' do
        expect do
          post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers

          @offer.reload
        end.to change { Offer.count }.from( 2 ).to( 1 )
      end

      it 'performs push notifications job' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers
        end.to have_enqueued_job( PushNotification::HireJob ).with @offer.id
      end
    end

    context 'when charge params are invalid' do
      before :each, with_before: true do
        allow( Stripe::Charge ).to receive( :create ).and_raise Stripe::InvalidRequestError.new( 'Must provide source or customer.', nil )

        post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers
      end

      it 'returns unprocessable response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns stripe errors', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ 'Must provide source or customer.' ]
        )
      end

      it 'does not change accepted field' do
        expect do
          allow( Stripe::Charge ).to receive( :create ).and_raise Stripe::InvalidRequestError.new( nil, nil )

          post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers

          @offer.reload
        end.to_not( change { @offer.accepted } )
      end

      it 'does not remove remaining offers' do
        expect do
          post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers

          @offer.reload
        end.to_not( change { Offer.count } )
      end
    end

    context 'when offer is not found' do
      let( :charge_attrs ) { attributes_for :charge }

      before do
        @offer.update accepted: true
      end

      before :each, with_before: true do
        post_json "/v1/offers/#{ @offer.id }/accept", params: { charge: charge_attrs }, headers: auth_headers
      end

      it 'returns not found response status', :with_before do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'offer.errors.not_found' ) ]
        )
      end

      it 'does not change accepted field' do
        expect do
          post_json "/v1/offers/#{ @offer.id }/accept", headers: auth_headers

          @offer.reload
        end.to_not( change { @offer.accepted } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :charge_attrs ) { attributes_for :charge }

    before do
      post_json '/v1/offers/0/accept', params: { charge: charge_attrs }, headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/offers/0/accept'
end

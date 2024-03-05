require 'rails_helper'

RSpec.describe 'POST v1/service_requests' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Create

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :vehicle ) { create :vehicle, client: account.accountable }
    let( :charge_attrs ) { attributes_for :charge }

    context 'when service_request params are valid' do
      before do
        allow_any_instance_of( StripePaymentsService ).to receive( :call ).and_return OpenStruct.new( paid: true )
      end

      let( :service_request_attrs ) do
        attributes_for :service_request_with_fake_pictures, vehicle_id: vehicle.id
      end

      before :each, with_before: true do
        fake_pictures_for ServiceRequest

        post_json '/v1/service_requests', params: {
          service_request: service_request_attrs,
          charge: charge_attrs
        }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        request = ServiceRequest.last

        expect( json ).to eq(
          'status' => 'success',
          'service_request' => service_request_response( request ).merge(
            'offers' => request.offers.map do | offer |
              offer_response offer
            end
          )
        )
      end

      it 'creates service request record' do
        expect do
          service_request_attrs[ :pictures_attributes ] = attributes_for_list :picture, 2
          service_request_attrs[ :category ] = ServiceRequest.categories.keys[ service_request_attrs[ :category ] ]

          post '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to change { ServiceRequest.count }.by( 1 ).and(
          change { Picture.count }.from( 0 ).to( 2 )
        )
      end

      it 'performs push notifications job' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          fake_pictures_for ServiceRequest

          post_json '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to have_enqueued_job PushNotification::NewServiceRequestJob
      end
    end

    context 'when charge params are invalid' do
      let( :service_request_attrs ) do
        attributes_for :service_request_with_fake_pictures, vehicle_id: vehicle.id
      end

      before :each, with_before: true do
        fake_pictures_for ServiceRequest
        allow( Stripe::Charge ).to receive( :create ).and_raise Stripe::InvalidRequestError.new( 'Must provide source or customer.', nil )

        post_json '/v1/service_requests', params: {
          service_request: service_request_attrs,
          charge: charge_attrs
        }, headers: auth_headers
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

      it 'does not create service request record' do
        expect do
          allow( Stripe::Charge ).to receive( :create ).and_raise Stripe::InvalidRequestError.new( nil, nil )

          service_request_attrs[ :pictures_attributes ] = attributes_for_list :picture, 2
          service_request_attrs[ :category ] = ServiceRequest.categories.keys[ service_request_attrs[ :category ] ]

          post '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to_not( change { ServiceRequest.count } )
      end
    end

    context 'when fee is zero' do
      let( :service_request_attrs ) do
        attributes_for :service_request_with_fake_pictures, vehicle_id: vehicle.id
      end

      before do
        Setting.service_request_fee = 0
      end

      before :each, with_before: true do
        fake_pictures_for ServiceRequest

        post_json '/v1/service_requests', params: {
          service_request: service_request_attrs
        }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        request = ServiceRequest.last

        expect( json ).to eq(
          'status' => 'success',
          'service_request' => service_request_response( request ).merge(
            'offers' => request.offers.map do | offer |
              offer_response offer
            end
          )
        )
      end

      it 'creates service request record' do
        expect do
          service_request_attrs[ :pictures_attributes ] = attributes_for_list :picture, 2
          service_request_attrs[ :category ] = ServiceRequest.categories.keys[ service_request_attrs[ :category ] ]

          post '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to change { ServiceRequest.count }.by( 1 ).and(
          change { Picture.count }.from( 0 ).to( 2 )
        )
      end

      it 'performs push notifications job' do
        ActiveJob::Base.queue_adapter = :test

        expect do
          fake_pictures_for ServiceRequest

          post_json '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to have_enqueued_job PushNotification::NewServiceRequestJob
      end
    end

    context 'when service request params are invalid' do
      before do
        allow_any_instance_of( StripePaymentsService ).to receive( :call ).and_return OpenStruct.new( paid: true )
      end

      let( :service_request_attrs ) do
        attributes_for :service_request_with_fake_pictures, vehicle_id: vehicle.id, summary: nil
      end

      before :each, with_before: true do
        fake_pictures_for ServiceRequest

        post_json '/v1/service_requests', params: {
          service_request: service_request_attrs,
          charge: charge_attrs
        }, headers: auth_headers
      end

      it 'returns unprocessable response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns service request errors messages', :with_before, :dox do
        service_request = vehicle.service_requests.build service_request_attrs
        service_request.save

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( service_request ),
          'service_request' => service_request_response( service_request ).merge(
            'offers' => service_request.offers.map do | offer |
              offer_response offer
            end
          )
        )
      end

      it 'creates no service_request records' do
        expect do
          post_json '/v1/service_requests', params: {
            service_request: service_request_attrs,
            charge: charge_attrs
          }, headers: auth_headers
        end.to_not( change { ServiceRequest.count } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }
    let( :service_request_attrs ) { attributes_for :service_request }
    let( :charge_attrs ) { attributes_for :charge }

    before do
      post_json '/v1/service_requests', params: {
        service_request: service_request_attrs,
        charge: charge_attrs
      }, headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/service_requests'
end

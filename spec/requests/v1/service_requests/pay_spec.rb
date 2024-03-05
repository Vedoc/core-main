require 'rails_helper'

RSpec.describe 'POST v1/service_requests/:id/pay' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Pay

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      vehicle = create :vehicle, client: account.accountable
      @service_request = create :service_request, vehicle: vehicle

      @offer = create :offer, accepted: true, service_request: @service_request, shop: create( :shop )
    end

    context 'when service request is found' do
      before :each, with_before: true do
        post_json "/v1/service_requests/#{ @service_request.id }/pay", headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq 'status' => 'success'
      end

      it 'changes service request status' do
        expect do
          post_json "/v1/service_requests/#{ @service_request.id }/pay", headers: auth_headers

          @service_request.reload
        end.to change { @service_request.status }.from( 'in_repair' ).to( 'done' )
      end
    end

    context 'when service_request is not found' do
      let!( :new_account ) { create :account }
      let( :auth_headers ) { new_account.create_new_auth_token }

      before :each, with_before: true do
        post_json "/v1/service_requests/#{ @service_request.id }/pay", headers: auth_headers
      end

      it 'returns not found response status', :with_before do
        expect( response ).to have_http_status :not_found
      end

      it 'returns a not found error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'service_request.errors.not_found' ) ]
        )
      end

      it 'does not change status' do
        expect do
          post_json "/v1/service_requests/#{ @service_request.id }/pay", headers: auth_headers

          @service_request.reload
        end.to_not( change { @service_request.status } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      post_json '/v1/service_requests/0/pay', headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/service_requests/0/pay'
end

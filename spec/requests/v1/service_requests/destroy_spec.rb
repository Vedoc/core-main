require 'rails_helper'

RSpec.describe 'DELETE v1/service_requests/:id' do
  include Docs::V1::ServiceRequests::Api
  include Docs::V1::ServiceRequests::Destroy

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }
    let!( :service_request ) { create :service_request, vehicle: create( :vehicle, client: account.accountable ) }

    context 'when service request exists' do
      before :each, with_before: true do
        delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns success message', :with_before, :dox do
        expect( json ).to eq 'status' => 'success'
      end

      it 'removes a service request record' do
        expect { delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers }
          .to change { ServiceRequest.count }.from( 1 ).to 0
      end
    end

    context 'when service request does not exist' do
      let!( :other_client ) { create( :account ).accountable }
      let!( :service_request ) { create :service_request, vehicle: create( :vehicle, client: other_client ) }

      before :each, with_before: true do
        delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns not found response status', :with_before do
        expect( response ).to have_http_status :not_found
      end

      it 'returns not found error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'service_request.errors.not_found' ) ]
        )
      end

      it 'does not destroy any service request' do
        expect { delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers }
          .to_not( change { ServiceRequest.count } )
      end
    end

    context 'when service request cannot be destroyed' do
      before do
        allow_any_instance_of( ServiceRequest ).to receive( :destroy ).and_return false
      end

      before :each, with_before: true do
        delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers
      end

      it 'returns unprocessable response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns a cannot be destroyed message', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'service_request.errors.destroy' ) ]
        )
      end

      it 'does not remove a service request record' do
        expect { delete "/v1/service_requests/#{ service_request.id }", headers: auth_headers }
          .to_not( change { ServiceRequest.count } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      delete '/v1/service_requests/0', headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :delete, '/v1/service_requests/0'
end

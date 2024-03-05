require 'rails_helper'

RSpec.shared_examples 'unauthenticated' do | method, path, params = {} |
  context 'when account is not authenticated' do
    before { send( method, path, params: params ) }

    it 'returns unauthorized response status' do
      expect( response ).to have_http_status :unauthorized
    end

    it 'returns an account unauthenticated message', :dox do
      expect( json ).to eq(
        'status' => 'error',
        'errors' => [ I18n.t( 'devise.failure.unauthenticated' ) ]
      )
    end
  end
end

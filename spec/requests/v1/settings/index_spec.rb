require 'rails_helper'

RSpec.describe 'GET v1/settings' do
  include Docs::V1::Settings::Api
  include Docs::V1::Settings::Index

  context 'when account is a client' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before { get '/v1/settings', headers: auth_headers }

    it 'returns success response status' do
      expect( response ).to have_http_status :ok
    end

    it 'returns list of settings', :dox do
      expect( json ).to eq(
        'status' => 'success',
        'settings' => Setting.get_all
      )
    end
  end

  it_behaves_like 'unauthenticated', :get, '/v1/settings'
end

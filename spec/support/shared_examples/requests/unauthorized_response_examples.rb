require 'rails_helper'

RSpec.shared_examples 'unauthorized_response' do
  it 'returns unauthorized response status' do
    expect( response ).to have_http_status :forbidden
  end

  it 'returns an account unauthorized message', :dox do
    expect( json ).to eq(
      'status' => 'error',
      'errors' => [ I18n.t( 'pundit.errors.unauthorized' ) ]
    )
  end
end

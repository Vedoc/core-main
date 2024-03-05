require 'rails_helper'

RSpec.describe 'POST v1/offers/:id/ratings' do
  include Docs::V1::Ratings::Api
  include Docs::V1::Ratings::Create

  context 'when account is a client' do
    let( :rating ) { build :rating }
    let( :auth_headers ) { rating.client.account.create_new_auth_token }

    context 'when rating params are valid' do
      before :each, with_before: true do
        post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
          rating: { score: rating.score }
        }, headers: auth_headers
      end

      it 'returns success response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'success',
          'rating' => rating_response( rating )
        )
      end

      it 'creates rating record' do
        expect do
          post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
            rating: { score: rating.score }
          }, headers: auth_headers
        end.to change { Rating.count }.by 1
      end
    end

    context 'when offer not found' do
      let( :auth_headers ) { create( :account ).create_new_auth_token }

      before :each, with_before: true do
        post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
          rating: { score: rating.score }
        }, headers: auth_headers
      end

      it 'returns not found response status', :with_before do
        expect( response ).to have_http_status :not_found
      end

      it 'returns not found error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'offer.errors.not_found' ) ]
        )
      end

      it 'does not create rating record' do
        expect do
          post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
            rating: { score: rating.score }
          }, headers: auth_headers
        end.to_not( change { Rating.count } )
      end
    end

    context 'when rating params are invalid' do
      before { rating.score = 6 }

      before :each, with_before: true do
        post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
          rating: { score: rating.score }
        }, headers: auth_headers
      end

      it 'returns unprocessable entity response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns rating error messages', :with_before, :dox do
        rating.save

        expect( json ).to eq(
          'status' => 'error',
          'errors' => resource_errors( rating )
        )
      end

      it 'creates no vehicle records' do
        expect do
          post_json "/v1/offers/#{ rating.offer.id }/ratings", params: {
            rating: { score: rating.score }
          }, headers: auth_headers
        end.to_not( change { Rating.count } )
      end
    end
  end

  context 'when account is not a client' do
    let!( :account ) { create :business_account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      post_json '/v1/offers/1/ratings', params: { rating: { score: 1 } }, headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/offers/1/ratings'
end

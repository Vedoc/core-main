require 'rails_helper'

RSpec.describe 'POST v1/promo_codes' do
  include Docs::V1::PromoCodes::Api
  include Docs::V1::PromoCodes::Create

  context 'when account is a business owner' do
    context 'when email params is present' do
      let!( :account ) { create :business_account }
      let( :auth_headers ) { account.create_new_auth_token }

      before :each, with_before: true do
        post_json '/v1/promo_codes', params: { email: 'test@mail.com' },
                                     headers: auth_headers
      end

      it 'returns unauthorized response status', :with_before do
        expect( response ).to have_http_status :ok
      end

      it 'returns a success status', :with_before, :dox do
        expect( json ).to eq 'status' => 'success'
      end

      it 'sends an email' do
        expect { post_json '/v1/promo_codes', params: { email: 'test@mail.com' }, headers: auth_headers }
          .to change { ActionMailer::Base.deliveries.count }.by 1
      end

      it 'creates promo code record' do
        expect { post_json '/v1/promo_codes', params: { email: 'test@mail.com' }, headers: auth_headers }
          .to change { PromoCode.count }.by 1
      end

      it 'sets code attributes', :with_before do
        promo_code = PromoCode.last

        expect( promo_code.sent_at.present? ).to eq true
        expect( promo_code.code_token.present? ).to eq true
      end
    end

    context 'when email params is not present' do
      let!( :account ) { create :business_account }
      let( :auth_headers ) { account.create_new_auth_token }

      before :each, with_before: true do
        post_json '/v1/promo_codes', params: { email: nil }, headers: auth_headers
      end

      it 'returns unauthorized response status', :with_before do
        expect( response ).to have_http_status :unprocessable_entity
      end

      it 'returns an email blank error', :with_before, :dox do
        expect( json ).to eq(
          'status' => 'error',
          'errors' => [ I18n.t( 'promo_code.errors.email' ) ]
        )
      end

      it 'sends no emails' do
        expect { post_json '/v1/promo_codes', params: { email: nil }, headers: auth_headers }
          .to_not( change { ActionMailer::Base.deliveries.count } )
      end

      it 'creates no code record' do
        expect { post_json '/v1/promo_codes', params: { email: nil }, headers: auth_headers }
          .to_not( change { PromoCode.count } )
      end
    end
  end

  context 'when account is not a business owner' do
    let!( :account ) { create :account }
    let( :auth_headers ) { account.create_new_auth_token }

    before do
      post_json '/v1/promo_codes', params: { email: 'test@mail.com' },
                                   headers: auth_headers
    end

    include_examples 'unauthorized_response'
  end

  it_behaves_like 'unauthenticated', :post_json, '/v1/promo_codes', params: { email: 'test@mail.com' }
end

module V1
  class PromoCodesController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!
    before_action :set_promo_code

    def create
      PromoCodeMailer.invitation(
        email: @promo_code.email,
        code: @promo_code.set_code_token,
        shop: current_account.accountable
      ).deliver_later

      render json: { status: 'success' }
    end

    private

    def authorize_account!
      authorize PromoCode.new
    end

    def set_promo_code
      @promo_code = PromoCode.new email: params[ :email ], shop: current_account.accountable

      render_errors( errors: @promo_code.errors.full_messages ) unless @promo_code.save
    end
  end
end

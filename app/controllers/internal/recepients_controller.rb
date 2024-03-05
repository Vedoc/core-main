module Internal
  class RecepientsController < ApplicationController
    before_action :authenticate_account!

    def show
      @offer = Offer.find_by id: params[ :offer_id ]

      return render_errors errors: [ I18n.t( 'recepient.errors.not_found' ) ], status: :not_found unless @offer

      @recepient = current_account.client? ? @offer.shop : @offer.client
    end
  end
end

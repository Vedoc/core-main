module V1
  class ClientsController < ApplicationController
    before_action :authenticate_account!
    before_action :authorize_account!

    def show
      @client = Client.find_by id: params[ :id ]

      render_errors( errors: [ I18n.t( 'client.errors.not_found' ) ], status: :not_found ) unless @client
    end

    private

    def authorize_account!
      authorize Client.new
    end
  end
end

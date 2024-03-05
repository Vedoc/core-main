module V1
  class PasswordResetsController < ApplicationController
    def create
      reset_token = params[ :token ].to_s
      email = params[ :email ]

      if ( token = Redis.current.get( email ) ) && token == reset_token
        account = Account.find_by email: email
        Redis.current.del email
      end

      return render_not_found unless account
      return render_success if account.update( password: params[ :password ] )

      render_errors errors: account.errors.full_messages
    end

    private

    def render_not_found
      render_errors errors: [ I18n.t( 'password_reset.errors.not_found' ) ], status: :not_found
    end

    def render_success
      render json: { status: :success, message: I18n.t( 'password_reset.success' ) }
    end
  end
end

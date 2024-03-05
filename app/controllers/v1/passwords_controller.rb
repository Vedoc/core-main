module V1
  class PasswordsController < DeviseTokenAuth::PasswordsController
    protected

    def render_create_success
      render json: {
        status: 'success',
        password_reset_duration: Setting.password_reset_duration,
        message: I18n.t( 'devise_token_auth.passwords.sended', email: @email )
      }
    end

    def render_not_found_error
      errors = [ I18n.t( 'devise_token_auth.passwords.user_not_found', email: @email ) ]

      render_errors errors: errors, status: :not_found
    end
  end
end

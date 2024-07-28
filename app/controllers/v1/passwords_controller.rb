# app/controllers/v1/passwords_controller.rb
module V1
  class PasswordsController < DeviseTokenAuth::PasswordsController
    protected

    def render_create_success
      render json: {
        status: 'success',
        password_reset_duration: Setting.password_reset_duration,
        message: I18n.t('devise_token_auth.passwords.sended', email: @email)
      }
    end

    def render_create_error
      render_errors(
        errors: [I18n.t('devise_token_auth.passwords.user_not_found', email: @email)],
        status: :not_found
      )
    end
  end
end

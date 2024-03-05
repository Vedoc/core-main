module V1
  class TokenValidationsController < DeviseTokenAuth::TokenValidationsController
    protected

    def render_validate_token_success; end

    def render_validate_token_error
      render_errors(
        errors: [ I18n.t( 'devise_token_auth.token_validations.invalid' ) ],
        status: :unauthorized
      )
    end
  end
end

module V1
  class SessionsController < DeviseTokenAuth::SessionsController
    def create
      super do
        create_or_update_device
      end
    end

    def destroy
      super do | account |
        return unless params[ :device_id ]

        account.devices.where(
          device_id: params[ :device_id ], platform: params[ :platform ]
        ).destroy_all
      end
    end

    def render_create_success; end

    def render_create_error_bad_credentials
      render_errors(
        errors: [ I18n.t( 'devise_token_auth.sessions.bad_credentials' ) ],
        status: :unauthorized
      )
    end

    def render_destroy_success
      render json: { status: 'success' }
    end

    def render_create_error_not_confirmed
      render_errors(
        errors: [ I18n.t( 'devise_token_auth.sessions.not_confirmed' ) ],
        status: :unauthorized
      )
    end

    def render_destroy_error
      render_errors(
        errors: [ I18n.t( 'devise_token_auth.sessions.user_not_found' ) ],
        status: :not_found
      )
    end
  end
end

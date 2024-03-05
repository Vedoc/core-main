class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit

  rescue_from Pundit::NotAuthorizedError, with: :account_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  alias authenticate_account! authenticate_v1_account!
  alias current_account current_v1_account

  def render_authenticate_error
    render_errors errors: [ I18n.t( 'devise.failure.unauthenticated' ) ], status: :unauthorized
  end

  def pundit_user
    current_account
  end

  def render_errors( errors: [], status: :unprocessable_entity )
    render 'v1/shared/errors', locals: { errors: errors }, status: status
  end

  def configure_permitted_parameters
    device_params = %i[device_id device_token platform]

    devise_parameter_sanitizer.permit(
      :sign_up, keys: %i[
        email password zip_code phone
      ]
    )

    devise_parameter_sanitizer.permit(
      :sign_in, keys: [
        :email, :password, device: device_params
      ]
    )
  end

  def device_params
    return if params[ :device ].blank?

    params.require( :device ).permit :device_id, :device_token, :platform
  end

  def create_or_update_device
    return if device_params.blank?

    @device = Device.find_by(
      platform: device_params[ :platform ],
      device_id: device_params[ :device_id ],
      account_id: @resource.id
    )

    return @device = Device.create( device_params.merge( account_id: @resource.id ) ) unless @device

    @device.update device_params
  end

  private

  def account_not_authorized
    render_errors errors: [ I18n.t( 'pundit.errors.unauthorized' ) ], status: :forbidden
  end
end

class ApplicationController < ActionController::API
  include DeviseTokenAuth::Concerns::SetUserByToken
  include Pundit::Authorization

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
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [
        :email,
        :password,
        :zip_code,
        :phone
      ]
    )

    devise_parameter_sanitizer.permit(
      :sign_in,
      keys: [
        :email,
        :password
      ]
    )
  end

  def device_params
    return {} if params[:device].blank?

    params.require(:device).permit(:device_id, :device_token, :platform)
  end

  def create_or_update_device(device_params)
    return if device_params.blank?

    Account.transaction do
      @device = Device.find_or_initialize_by(
        platform: device_params[:platform],
        device_id: device_params[:device_id],
        account_id: @resource.id
      )

      @device.assign_attributes(device_params)
      @device.save!
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("Device creation failed: #{e.message}")
    false
  end

  private

  def account_not_authorized
    render_errors errors: [ I18n.t( 'pundit.errors.unauthorized' ) ], status: :forbidden
  end
end

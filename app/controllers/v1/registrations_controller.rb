module V1
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    def create
      super do
        @promo_code&.update activated_at: Time.now.utc
        create_or_update_device
      end
    end

    def update
      if @resource
        authorize @resource

        accountable_params = @resource.business_owner? ? shop_params : client_params

        @resource.accountable.assign_attributes accountable_params.to_h
      end

      super
    end

    protected

    def build_resource
      super

      if params[ :promo_code ].present?

        @promo_code = PromoCode.with_code_token params[ :promo_code ]

        return if @promo_code.blank? || @promo_code.expired?

        @resource.employee = true

        return @resource.accountable = @promo_code.shop
      end

      return @resource.accountable = Shop.new( shop_params ) if params[ :shop ].present?

      @resource.accountable = Client.new client_params
    end

    def validate_account_update_params; end

    def render_update_error_user_not_found
      render_authenticate_error
    end

    def render_create_success; end

    def render_update_success; end

    def render_create_error
      set_promo_code_errors

      render :error, status: :unprocessable_entity
    end

    def render_update_error
      render_create_error
    end

    def client_params
      return if params[ :client ].blank?

      params.require( :client ).permit :name, :phone, :avatar, :address, location: %i[lat long]
    end

    def shop_params
      return if params[ :shop ].blank?

      params.require( :shop ).permit(
        :name, :hours_of_operation, :techs_per_shift, :phone, :address, :vehicle_diesel,
        :certified, :lounge_area, :supervisor_permanently, :tow_track, :owner_name,
        :complimentary_inspection, :vehicle_warranties, :vehicle_electric, :avatar, :additional_info,
        categories: [], languages: [], pictures_attributes: %i[id data _destroy], location: %i[lat long]
      )
    end

    def set_promo_code_errors
      return if params[ :promo_code ].blank?

      @resource.errors.delete :accountable

      if @promo_code.blank?
        @resource.errors.add :promo_code, 'not found'
      elsif @promo_code.expired?
        @resource.errors.add :promo_code, 'has expired'
      end
    end
  end
end

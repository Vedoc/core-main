module V1
  class RegistrationsController < DeviseTokenAuth::RegistrationsController
    def create
      begin
        @promo_code_token = params.delete(:promo_code)
        @card_token = params.delete(:card_token)

        # Build the resource with parameters
        build_resource

        if @resource.save
          handle_promo_code_activation
          create_or_update_device(device_params)

          token_data = @resource.create_new_auth_token
          response.headers.merge!(token_data)

          render json: {
            auth: auth_data(token_data),
            account: resource_data(@resource),
            status: 'success'
          }, status: :created
        else
          render_errors(errors: @resource.errors.full_messages, status: :unprocessable_entity)
        end
      rescue StandardError => e
        Rails.logger.error("Registration error: #{e.message}")
        render_errors(errors: ['Registration failed. Please try again.'], status: :unprocessable_entity)
      end
    end

    def destroy
      # Check if email and password are provided
      unless params[:email].present? && params[:password].present?
        return render json: { errors: ['Email and password are required'] }, status: :unprocessable_entity
      end
      # Find the user by email
      user = Account.find_by(email: params[:email])
      if user && user.valid_password?(params[:password])
        # Destroy the user's account
        if user.destroy
          render json: { message: 'Account successfully deleted' }, status: :ok
        else
          render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
        end
      else
        render json: { errors: ['Invalid email or password'] }, status: :unauthorized
      end
    end

    protected

    def build_resource
      @resource = Account.new(account_params)
      assign_accountable_resource
    end

    def assign_accountable_resource
      if @promo_code_token.present?
        @promo_code = PromoCode.with_code_token(@promo_code_token)

        if @promo_code&.valid?
          @resource.employee = true
          @resource.accountable = @promo_code.shop
        end
      elsif params[:client].present?
        @resource.accountable = Client.new(client_params)
      elsif params[:shop].present?
        @resource.accountable = Shop.new(shop_params)
      end
    end

    def account_params
      params.permit(:email, :password)
    end

    def client_params
      params.require(:client).permit(:name, :phone, :avatar, :address, location: %i[lat long])
    end

    def shop_params
      params.require(:shop).permit(
        :name, :hours_of_operation, :techs_per_shift, :phone, :address, :vehicle_diesel,
        :certified, :lounge_area, :supervisor_permanently, :tow_track, :owner_name,
        :complimentary_inspection, :vehicle_warranties, :vehicle_electric, :avatar, :additional_info,
        categories: [], languages: [], pictures_attributes: %i[id data _destroy], location: %i[lat long]
      )
    end

    private

    def handle_promo_code_activation
      return unless @promo_code_token.present?

      @promo_code = PromoCode.with_code_token(@promo_code_token)
      return unless @promo_code&.valid?

      @promo_code.update(activated_at: Time.now.utc)
    end

    def auth_data(token_data)
      {
        'access-token': token_data['access-token'],
        client: token_data['client'],
        'token-type': token_data['token-type'],
        uid: token_data['uid']
      }
    end

    def resource_data(resource)
      {
        email: resource.email,
        employee: resource.employee,
        client: resource.client? ? client_data(resource.accountable) : nil,
        business_owner: resource.business_owner? ? shop_data(resource.accountable) : nil
      }
    end

    def client_data(client)
      {
        name: client.name,
        phone: client.phone,
        address: client.address,
        vehicles: client.vehicles,
        avatar: client.avatar_url,
        location: client.location,
        card_token: @card_token || ""
      }
    end

    def shop_data(shop)
      {
        name: shop.name,
        phone: shop.phone,
        address: shop.address,
        hours_of_operation: shop.hours_of_operation,
        techs_per_shift: shop.techs_per_shift,
        vehicle_diesel: shop.vehicle_diesel,
        certified: shop.certified,
        lounge_area: shop.lounge_area,
        supervisor_permanently: shop.supervisor_permanently,
        tow_track: shop.tow_track,
        owner_name: shop.owner_name,
        complimentary_inspection: shop.complimentary_inspection,
        vehicle_warranties: shop.vehicle_warranties,
        vehicle_electric: shop.vehicle_electric,
        avatar: shop.avatar_url,
        additional_info: shop.additional_info,
        categories: shop.categories,
        languages: shop.languages,
        location: shop.location
      }
    end
  end
end

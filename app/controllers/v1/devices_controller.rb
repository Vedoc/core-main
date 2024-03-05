module V1
  class DevicesController < ApplicationController
    before_action :authenticate_account!

    def create
      create_or_update_device

      render( :error, status: :unprocessable_entity ) unless @device.valid?
    end
  end
end

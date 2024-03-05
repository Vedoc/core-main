module V1
  class ProfilesController < ApplicationController
    before_action :authenticate_account!

    def show
      @account = current_account
    end
  end
end

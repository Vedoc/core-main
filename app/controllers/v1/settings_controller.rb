module V1
  class SettingsController < ApplicationController
    before_action :authenticate_account!

    def index
      @settings = Setting.get_all
    end
  end
end

require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'active_storage/engine'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'action_cable/engine'
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require( *Rails.groups )

module VedocApi
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration can go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded after loading
    # the framework and any gems in your application.

    config.middleware.use Rack::Attack unless Rails.env.test?

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.eager_load_paths << Rails.root.join( 'lib' )

    config.action_mailer.default_url_options = { host: ENV[ 'APP_HOST' ] }

    config.action_controller.action_on_unpermitted_parameters = :log

    config.active_job.queue_adapter = :sidekiq

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use ActionDispatch::Session::CookieStore
    config.middleware.use ActionDispatch::Flash

    Rails.application.config.hosts.clear
    config.action_dispatch.show_exceptions = true

    # Add this line to control auto-seeding
    config.auto_seed_production = ENV['AUTO_SEED_PRODUCTION'].present?
    # config.service_name = 'core'  # Identify this service
    # config.service_dependencies = ['my_admin']  # List services this depends on
  end
end
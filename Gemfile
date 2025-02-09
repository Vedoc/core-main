source 'https://rubygems.org'
git_source( :github ) { | repo | "https://github.com/#{ repo }.git" }

ruby '3.3.0'
# ruby '3.3.1'
# ruby '3.2.2'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 7.1.3.2'
# gem "rails", "~> 7.1.3", ">= 7.1.3.2"

# Vedoc app models
# gem 'vedoc-plugin', git: 'https://github.com/vedoc/vedoc-plugin.git', branch: 'main'
gem 'vedoc-plugin', git: 'https://github.com/vedoc/vedoc-plugin.git'


# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# ActiveRecord connection adapter for PostGIS, based on postgresql and rgeo
gem 'activerecord-postgis-adapter'

# Ruby ODM framework for MongoDB
# gem 'mongoid', '>= 7.0.0'

# Use Puma as the app server
# gem 'puma', '~> 3.11'
gem 'puma', '~> 6.4', '>= 6.4.2'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
# gem 'jbuilder', '~> 2.5'
# Use Redis adapter to run Action Cable in production
# gem 'redis', '~> 4.0'
# gem 'redis', '~> 5.1'

gem 'redis-namespace'
gem 'redis-rails'
# Simple, efficient background processing for Ruby
gem 'sidekiq'
gem 'sidekiq-cron'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use ActiveStorage variant
# gem 'mini_magick', '~> 4.8'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Reduces boot times through caching; required in config/boot.rb
# gem 'bootsnap', '>= 1.1.0', require: false
gem 'bootsnap', '~> 1.18.3', require: false

# gem 'rails-settings'

# gem 'rails-settings-cached'

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin AJAX possible
# gem 'rack-cors'

# Simple, multi-client and secure token-based authentication for Rails
gem 'devise_token_auth', git: 'https://github.com/lynndylanhurley/devise_token_auth'

# Ruby templating system for generating JSON
gem 'oj'
gem 'rabl'

# Solution for file uploads
gem 'carrierwave'
gem 'fog-aws'

# Rack middleware for blocking & throttling
gem 'rack-attack'

# Authorization library
gem 'pundit'

# Ruby library for the Stripe API.
gem 'stripe'

gem 'rack-cors'

# Ruby bindings to Firebase Cloud Messaging
gem 'fcm'

# gem 'sprockets-rails'

# Manage settings with Ruby on Rails
gem 'rails-settings-cached'

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution
  # and get a debugger console
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  # A code metric tool for rails projects
  gem 'rails_best_practices', require: false
  # Ruby static code analyzer and code formatter
  gem 'rubocop', require: false
  # Testing framework
  gem 'rspec-rails', '~> 3.8'
  # Fixtures replacement
  gem 'factory_bot_rails'
  # Generate fake data
  gem 'faker'
  # Shim to load environment variables from .env into ENV in development
  # gem 'dotenv-rails'
  gem 'dotenv-rails', groups: [:development, :test]

  # Allows to automatically & intelligently launch specs when files are modified
  gem 'guard-rspec', require: false
end

group :development do
  # gem 'listen', '>= 3.0.5', '< 3.2'
  gem 'listen', '~> 3.5'
  # Spring speeds up development by keeping your application running in the
  # background. Read more: https://github.com/rails/spring
  # gem 'spring'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  # An alternative to the standard IRB shell for Ruby.
  gem 'pry-rails'
  # Static analysis tool which checks Ruby on Rails applications
  # for security vulnerabilities
  gem 'brakeman', require: false
end

group :test do
  # Code coverage
  gem 'simplecov', require: false
  # Set of strategies for cleaning the database
  gem 'database_cleaner'
  # RSpec- and Minitest-compatible one-liners that
  # test common Rails functionality.
  gem 'shoulda-matchers', '4.0.0.rc1'
  # Automated API documentation from Rspec
  gem 'dox', require: false
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'ffi', '~> 1.15'

gem 'smarter_csv'

gem 'omniauth'

gem 'utf8-cleaner'

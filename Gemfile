source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.1'

gem "rails", "~> 7.1.3"

gem 'vedoc-plugin', git: 'https://github.com/vedoc/vedoc-plugin.git'

gem 'pg', '>= 0.18', '< 2.0'
gem 'activerecord-postgis-adapter'
gem 'mongoid', '>= 7.0.0'
gem 'puma', '~> 6.4', '>= 6.4.2'
gem 'redis-namespace'
gem 'redis-rails'
gem 'sidekiq'
gem 'sidekiq-cron'
gem 'bootsnap', '~> 1.18.3', require: false
gem 'devise_token_auth', git: 'https://github.com/lynndylanhurley/devise_token_auth'
gem 'oj'
gem 'rabl'
gem 'carrierwave'
gem 'fog-aws'
gem 'csv'
gem 'rack-attack'
gem 'pundit'
gem 'stripe'
gem 'fcm'
gem 'rails-settings-cached'

group :development, :test do
  gem 'byebug', platforms: %i[mri mingw x64_mingw]
  gem 'rails_best_practices', require: false
  gem 'rubocop', require: false
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'dotenv-rails', groups: [:development, :test]
  gem 'guard-rspec', require: false
  gem 'rspec-rails'
  gem 'rswag-specs'
end

group :development do
  gem 'listen', '~> 3.5'
  # gem 'spring', '~> 2.1'
  # gem 'spring-watcher-listen', '~> 2.0.0'
  gem 'pry-rails'
  gem 'brakeman', require: false
end

group :test do
  gem 'simplecov', require: false
  gem 'database_cleaner'
  gem 'shoulda-matchers', '4.0.0.rc1'
  # gem 'dox', require: false
  # gem 'dox', '~> 2.3.0' 
end

gem 'tzinfo-data', platforms: %i[mingw mswin x64_mingw jruby]

gem 'rswag-api'
gem 'rswag-ui'
# gem 'swagger-blocks'
# gem 'rswag-specs'

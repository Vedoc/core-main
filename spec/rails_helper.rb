require 'spec_helper'
ENV[ 'RAILS_ENV' ] ||= 'test'
require File.expand_path( '../config/environment', __dir__ )
# Prevent database truncation if the environment is production
abort( 'The Rails environment is running in production mode!' ) if Rails.env.production?
require 'rspec/rails'
require 'dox'

Dir[ Rails.root.join( 'spec', 'support', '**', '*.rb' ) ].each { | f | require f }
Dir[ Rails.root.join( 'spec/docs/**/*.rb' ) ].each { | f | require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

Shoulda::Matchers.configure do | config |
  config.integrate do | with |
    with.test_framework :rspec
    with.library :rails
  end
end

Dox.configure do | config |
  config.header_file_path = Rails.root.join( 'spec/docs/v1/descriptions/header.md' )
  config.desc_folder_path = Rails.root.join( 'spec/docs/v1/descriptions' )
  config.headers_whitelist = [ 'Accept', 'uid', 'token-type', 'expiry', 'access-token', 'client' ]
end

RSpec.configure do | config |
  config.include Helpers::Request, type: :request

  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end

# Define custom configuration options
module SeedConfiguration
  extend ActiveSupport::Concern
  
  included do
    config_accessor :auto_seed_production, :allow_production_seeds, :service_dependencies
  end
end

Rails::Application::Configuration.include(SeedConfiguration)

# Configure seeding options first
Rails.application.configure do
  # Allow manual seeding in production if explicitly enabled
  config.x.allow_production_seeds = ENV['ALLOW_PRODUCTION_SEEDS'].present?
end

# Prevent accidental seeding in production unless explicitly allowed
if Rails.env.production? && !Rails.application.config.x.allow_production_seeds
  puts "WARNING: Seeding in production is disabled by default."
  puts "To enable, set ALLOW_PRODUCTION_SEEDS=true in your environment."
  abort("Aborting seed operation in production") unless ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'].present?
end

# Check if we need to seed
begin
  # Convert files to UTF-8 first
  %w[clients accounts shops vehicles].each do |file|
    path = Rails.root.join('db', 'seeds', "#{file}.csv")
    next unless File.exist?(path)
    
    content = File.read(path)
    content.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace, replace: '?')
    content.sub!("\xEF\xBB\xBF", '') # Remove BOM if present
    
    File.write(path, content)
  end
rescue => e
  Rails.logger.error "Error preparing seed files: #{e.message}"
  Rails.logger.error e.backtrace.join("\n")
end

# Only run automatic seeding in production if enabled
if Rails.env.production? && Rails.application.config.auto_seed_production
  begin
    # Check if we need to seed
    if defined?(Client) && defined?(Shop) && defined?(Vehicle) &&
       (Client.count.zero? || Shop.count.zero? || Vehicle.count.zero?)
      puts "Database appears empty. Starting automatic seed process..."
      
      # Convert files to UTF-8 first
      %w[clients accounts shops vehicles].each do |file|
        path = Rails.root.join('db', 'seeds', "#{file}.csv")
        next unless File.exist?(path)
        
        content = File.read(path)
        content.encode!('UTF-8', 'UTF-8', invalid: :replace, undef: :replace, replace: '?')
        content.sub!("\xEF\xBB\xBF", '') # Remove BOM if present
        
        File.write(path, content)
      end

      # Run seeds
      Rake::Task['db:seed:all'].invoke
    end
  rescue => e
    Rails.logger.error "Error during seeding: #{e.message}"
    Rails.logger.error e.backtrace.join("\n")
  end
end 
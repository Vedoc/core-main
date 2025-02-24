# Only run in production and if DB exists
if Rails.env.production? && Rails.application.config.auto_seed_production
  begin
    # Wait for dependent services to be ready
    Rails.application.config.service_dependencies.each do |service|
      retries = 0
      max_retries = 30  # 5 minutes total (10 seconds * 30)
      
      until retries >= max_retries
        begin
          # Try to connect to dependent service's health check endpoint
          uri = URI("http://#{service}/health")
          response = Net::HTTP.get_response(uri)
          
          break if response.is_a?(Net::HTTPSuccess)
        rescue StandardError => e
          Rails.logger.warn "Waiting for #{service} to be ready... (#{retries + 1}/#{max_retries})"
          retries += 1
          sleep 10
        end
      end
      
      if retries >= max_retries
        Rails.logger.error "Timeout waiting for #{service} service"
        exit 1
      end
    end

    # Check if we need to seed
    if Client.count.zero? || Shop.count.zero? || Vehicle.count.zero?
      puts "Database appears empty. Starting automatic seed process..."
      
      # Run seeds asynchronously to not block server startup
      Thread.new do
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

          # Run seeds
          Rake::Task['db:seed:all'].invoke
        rescue => e
          Rails.logger.error "Error during automatic seeding: #{e.message}"
          Rails.logger.error e.backtrace.join("\n")
        end
      end
    end
  rescue => e
    Rails.logger.error "Error checking database: #{e.message}"
  end
end

Rails.application.configure do
  # Only allow seeding in production if explicitly enabled
  config.allow_production_seeds = ENV['ALLOW_PRODUCTION_SEEDS'].present?
end

# Prevent accidental seeding in production unless explicitly allowed
if Rails.env.production? && !Rails.application.config.allow_production_seeds
  puts "WARNING: Seeding in production is disabled by default."
  puts "To enable, set ALLOW_PRODUCTION_SEEDS=true in your environment."
  abort("Aborting seed operation in production") unless ENV['DISABLE_DATABASE_ENVIRONMENT_CHECK'].present?
end 
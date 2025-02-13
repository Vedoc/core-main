# Only run in production and if DB exists
if Rails.env.production? && 
   Rails.application.config.auto_seed_production && 
   ActiveRecord::Base.connection.table_exists?('clients')
  begin
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
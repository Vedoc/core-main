module ImportOptimizations
  def self.with_import_optimizations
    # Get the database connection
    connection = ActiveRecord::Base.connection
    
    # Save current settings
    original_settings = {
      synchronous_commit: connection.execute("SHOW synchronous_commit").first["synchronous_commit"],
      wal_level: connection.execute("SHOW wal_level").first["wal_level"]
    }
    
    begin
      # Optimize PostgreSQL for bulk imports (if possible)
      begin
        connection.execute("SET synchronous_commit TO OFF")
        connection.execute("SET wal_level TO minimal") if Rails.env.development?
      rescue => e
        puts "Warning: Could not optimize database settings: #{e.message}"
      end
      
      # Disable SQL logging
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      
      # Execute the import
      yield
      
    ensure
      # Restore settings
      begin
        connection.execute("SET synchronous_commit TO #{original_settings[:synchronous_commit]}")
        connection.execute("SET wal_level TO #{original_settings[:wal_level]}") if Rails.env.development?
      rescue => e
        puts "Warning: Could not restore database settings: #{e.message}"
      end
      
      # Restore logger
      ActiveRecord::Base.logger = old_logger
    end
  end
end 
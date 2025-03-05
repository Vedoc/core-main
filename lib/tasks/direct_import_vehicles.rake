require 'csv'

namespace :db do
  namespace :direct_seed do
    desc "Direct import vehicles from CSV with minimal overhead"
    task vehicles: :environment do
      start_time = Time.now
      puts "Starting direct vehicle import at #{start_time}"
      
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end

      # Find existing default client or create a new one
      default_client = begin
        Client.find_by(phone: '+1 (000) 000-0000')
      rescue => e
        puts "Error finding client: #{e.message}"
        nil
      end

      unless default_client
        puts "Creating default client..."
        default_client = Client.create!(
          name: 'Seed Client',
          phone: "+1 (000) 000-0000-#{Time.now.to_i}",
          address: 'Default Address',
          location: 'POINT(-95.3698 29.7604)'
        )
      end
      
      puts "Using default client with ID: #{default_client.id}"
      
      # Process in smaller batches
      batch_size = 100
      records = []
      counter = 0
      total_lines = 0
      
      begin
        total_lines = `wc -l "#{file_path}"`.strip.split(' ')[0].to_i - 1
        puts "Processing approximately #{total_lines} records"
      rescue => e
        puts "Could not count lines: #{e.message}"
      end
      
      # Disable SQL logging temporarily
      old_logger = ActiveRecord::Base.logger
      ActiveRecord::Base.logger = nil
      
      begin
        # Process file with simple CSV parsing
        CSV.foreach(file_path, headers: true) do |row|
          begin
            vehicle_data = {
              year: row['Year'],
              make: row['Make'],
              model: row['Model'],
              category: row['Category'],
              client_id: default_client.id,
              created_at: row['createdAt'] || Time.current,
              updated_at: row['updatedAt'] || Time.current
            }
            
            records << vehicle_data
            counter += 1
            
            if records.size >= batch_size
              # Use a regular create for better compatibility
              Vehicle.create!(records)
              puts "Imported #{counter} vehicles..."
              records = []
              
              # Force garbage collection to avoid memory issues
              GC.start if counter % 1000 == 0
            end
          rescue => e
            puts "Error processing row: #{e.message}"
          end
        end
        
        # Process remaining records
        if records.any?
          Vehicle.create!(records)
          puts "Imported final batch of #{records.size} vehicles"
        end
        
        end_time = Time.now
        duration = (end_time - start_time).round(2)
        puts "Vehicle import completed in #{duration} seconds. Imported #{counter} vehicles."
      ensure
        # Restore logger
        ActiveRecord::Base.logger = old_logger
      end
    end
    
    # Add a chunk-based approach for very large files
    desc "Import vehicles in chunks"
    task vehicles_chunked: :environment do
      chunk_size = (ENV['CHUNK_SIZE'] || 1000).to_i
      start_line = (ENV['START_LINE'] || 1).to_i
      end_line = (ENV['END_LINE'] || Float::INFINITY).to_i
      
      puts "Importing vehicles from line #{start_line} to #{end_line}, chunk size: #{chunk_size}"
      
      # Run the task with chunking parameters
      ENV['CHUNK_SIZE'] = chunk_size.to_s
      ENV['START_LINE'] = start_line.to_s
      ENV['END_LINE'] = end_line.to_s
      
      Rake::Task["db:direct_seed:vehicles_chunk"].invoke
    end
    
    # Task to process a specific chunk
    task vehicles_chunk: :environment do
      chunk_size = (ENV['CHUNK_SIZE'] || 1000).to_i
      start_line = (ENV['START_LINE'] || 1).to_i
      end_line = (ENV['END_LINE'] || Float::INFINITY).to_i
      
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      
      # Get default client
      default_client = Client.find_by(phone: '+1 (000) 000-0000') || 
                      Client.create!(
                        name: 'Seed Client',
                        phone: "+1 (000) 000-0000-#{Time.now.to_i}",
                        address: 'Default Address',
                        location: 'POINT(-95.3698 29.7604)'
                      )
      
      # Process specific lines
      counter = 0
      current_line = 0
      records = []
      
      CSV.foreach(file_path, headers: true) do |row|
        current_line += 1
        next if current_line < start_line
        break if current_line > end_line
        
        records << {
          year: row['Year'],
          make: row['Make'],
          model: row['Model'],
          category: row['Category'],
          client_id: default_client.id,
          created_at: row['createdAt'] || Time.current,
          updated_at: row['updatedAt'] || Time.current
        }
        
        counter += 1
        
        if records.size >= chunk_size
          Vehicle.insert_all(records)
          puts "Processed #{counter} vehicles in current chunk..."
          records = []
        end
      end
      
      # Process remaining records
      if records.any?
        Vehicle.insert_all(records)
        puts "Processed final #{records.size} vehicles in chunk"
      end
      
      puts "Chunk import completed. Processed #{counter} vehicles."
    end
  end
end 
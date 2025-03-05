require 'csv'

namespace :db do
  namespace :fast_seed do
    desc "Fast import vehicles from CSV"
    task vehicles: :environment do
      start_time = Time.now
      puts "Starting fast vehicle import at #{start_time}"
      
      file_path = Rails.root.join('db/seeds/vehicles.csv')
      unless File.exist?(file_path)
        puts "File not found: #{file_path}"
        exit
      end
      
      # Find or create default client
      default_client = Client.find_by(phone: '+1 (000) 000-0000') || 
                       Client.create!(
                         name: 'Seed Client',
                         phone: "+1 (000) 000-0000-#{Time.now.to_i}",
                         address: 'Default Address',
                         location: 'POINT(-95.3698 29.7604)'
                       )
      
      puts "Using default client with ID: #{default_client.id}"
      
      # Set larger batch size
      batch_size = 500
      
      # Skip ActiveRecord callbacks and validations for max speed
      Vehicle.skip_callback(:save, :after, :reindex) if Vehicle.respond_to?(:skip_callback) && Vehicle.method_defined?(:reindex)
      
      # Count total records
      total_lines = `wc -l "#{file_path}"`.strip.split(' ')[0].to_i - 1
      puts "Processing approximately #{total_lines} records"
      
      # Process in batches with raw SQL for maximum speed
      records = []
      counter = 0
      headers = nil
      year_index = make_index = model_index = category_index = created_at_index = updated_at_index = nil
      
      puts "Reading CSV file..."
      
      # Stream the file line by line
      File.open(file_path, "r:bom|utf-8") do |file|
        headers = file.gets.strip.split(',')
        year_index = headers.index('Year')
        make_index = headers.index('Make')
        model_index = headers.index('Model')
        category_index = headers.index('Category')
        created_at_index = headers.index('createdAt')
        updated_at_index = headers.index('updatedAt')
        
        puts "Found headers: #{headers.join(', ')}"
        
        while line = file.gets
          begin
            values = line.strip.split(',', -1)
            next if values.size < [year_index, make_index, model_index].compact.max
            
            records << {
              year: values[year_index],
              make: values[make_index],
              model: values[model_index],
              category: values[category_index],
              client_id: default_client.id,
              created_at: values[created_at_index] || Time.now,
              updated_at: values[updated_at_index] || Time.now
            }
            
            counter += 1
            
            # Process in batches
            if records.size >= batch_size
              Vehicle.insert_all(records)
              puts "Processed #{counter}/#{total_lines} vehicles..."
              records = []
            end
          rescue => e
            puts "Error processing line: #{line.inspect}"
            puts e.message
          end
        end
      end
      
      # Process remaining records
      if records.any?
        Vehicle.insert_all(records)
        puts "Processed final batch of #{records.size} vehicles"
      end
      
      end_time = Time.now
      duration = (end_time - start_time).round(2)
      puts "Vehicle import completed in #{duration} seconds"
      
      # Re-enable callbacks if disabled
      Vehicle.set_callback(:save, :after, :reindex) if Vehicle.respond_to?(:set_callback) && Vehicle.method_defined?(:reindex)
    end
  end
end 
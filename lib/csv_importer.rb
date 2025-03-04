module CsvImporter
  def self.process_csv(file_path, model_class, mapping, batch_size: 100)
    return puts "File not found: #{file_path}" unless File.exist?(file_path)

    puts "Starting import for #{model_class} from #{file_path}"
    
    # Try different encodings
    encodings = ['UTF-8', 'ISO-8859-1', 'Windows-1252']
    total_records = 0
    records_batch = []
    imported_count = 0
    
    begin
      # First count the total records for progress reporting
      total_records = File.foreach(file_path).count - 1 # Subtract header row
      puts "Found approximately #{total_records} records to process"
    rescue => e
      puts "Could not count records: #{e.message}. Continuing without total."
    end
    
    encodings.each do |encoding|
      begin
        puts "Trying encoding: #{encoding}"
        
        # Process the file in a streaming fashion
        # instead of loading all into memory
        File.open(file_path, "r:#{encoding}:UTF-8") do |file|
          # Skip BOM if present
          first_line = file.readline
          first_line = first_line.sub("\xEF\xBB\xBF", '')
          file.rewind if first_line.include?(',') # It's a header, rewind

          csv = CSV.new(file, headers: true)
          
          # Process in batches
          csv.each.with_index(1) do |row, index|
            attributes = {}
            mapping.each do |target_key, source_key|
              value = row[source_key]
              attributes[target_key] = value unless value.nil?
            end
            
            yield(attributes, row) if block_given?
            
            # Add to batch
            records_batch << attributes
            
            # Process batch when it reaches batch_size
            if records_batch.size >= batch_size
              import_batch(model_class, records_batch)
              imported_count += records_batch.size
              puts "Processed #{imported_count}/#{total_records} records..." if total_records > 0
              records_batch = []
            end
            
            # Show progress for individual records too
            if index % 500 == 0
              puts "Read #{index} records so far..."
            end
          end
          
          # Process remaining records
          unless records_batch.empty?
            import_batch(model_class, records_batch)
            imported_count += records_batch.size
          end
          
          puts "Successfully imported #{imported_count} #{model_class} records"
          return true
        end
      rescue CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => e
        puts "Failed with encoding #{encoding}: #{e.message}"
        next
      rescue => e
        puts "Error during import: #{e.message}"
        puts e.backtrace.join("\n")[0..500] # Show limited backtrace
        next
      end
    end
    
    puts "Failed to process CSV with any known encoding"
    false
  end
  
  def self.import_batch(model_class, records)
    # Process in a transaction for better performance
    ActiveRecord::Base.transaction do
      records.each do |attributes|
        begin
          # Try to find existing record first
          existing = model_class.find_by(id: attributes[:id]) if attributes[:id].present?
          
          if existing
            existing.update!(attributes)
          else
            model_class.create!(attributes)
          end
        rescue ActiveRecord::RecordInvalid => e
          puts "Error saving record: #{e.message}"
          puts "Attributes: #{attributes.inspect}"
        end
      end
    end
  rescue => e
    puts "Error in batch import: #{e.message}"
  end
end 
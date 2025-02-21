module CsvImporter
  def self.process_csv(file_path, model_class, mapping)
    return puts "File not found: #{file_path}" unless File.exist?(file_path)

    encodings = ['UTF-8', 'ISO-8859-1', 'Windows-1252']
    
    encodings.each do |encoding|
      begin
        content = File.read(file_path, encoding: encoding)
        content = content.force_encoding('UTF-8')
        content = content.sub("\xEF\xBB\xBF", '') # Remove BOM
        
        CSV.parse(content, headers: true) do |row|
          attributes = {}
          mapping.each do |target_key, source_key|
            value = row[source_key]
            attributes[target_key] = value unless value.nil?
          end
          
          yield(attributes) if block_given?
          
          # Try to find existing record first
          existing = model_class.find_by(id: attributes[:id]) if attributes[:id]
          
          if existing
            existing.update!(attributes)
          else
            model_class.create!(attributes)
          end
        end
        
        puts "Successfully imported #{model_class} data"
        return true
      rescue CSV::MalformedCSVError, Encoding::InvalidByteSequenceError => e
        puts "Failed with encoding #{encoding}: #{e.message}"
        next
      rescue ActiveRecord::RecordInvalid => e
        puts "Error processing row: #{e.message}"
        next
      end
    end
    
    puts "Failed to process CSV with any known encoding"
    false
  end
end 
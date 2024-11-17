namespace :db do
  namespace :seed do
    task vehicles: :environment do
      begin
        # Ensure at least one CarCategory exists
        if CarCategory.count.zero?
          %w[car truck].each do |category|
            CarCategory.create!(name: category)
          end
        end

        # Open the CSV file for reading
        File.open(Rails.root.join('db/seeds/vehicles.csv'), 'r') do |file|
          csv = CSV.new(file, headers: true)

          csv.each do |row|
            begin
              # Ensure correct capitalization for the CSV headers
              make_name  = row['Make'] || row['make']
              model_name = row['Model'] || row['model']
              year       = row['Year'] || row['year']
              category   = row['Category'] || row['category']

              # Skip rows with missing data
              if make_name.nil? || model_name.nil? || year.nil? || category.nil?
                puts "Skipped row with missing data: #{row.to_h}"
                next
              end

              # Use an existing CarCategory or fallback to a default one
              car_category = CarCategory.find_by(name: category) || CarCategory.first

              # Create reference data
              make = CarMake.find_or_create_by!(name: make_name, car_category: car_category)
              model = CarModel.find_or_create_by!(name: model_name, car_make: make)
              ModelYear.find_or_create_by!(year: year, car_model: model)

              # Create the actual vehicle record
              Vehicle.create!(
                make: make_name,
                model: model_name,
                year: year,
                category: category
              )

              puts "Imported #{make_name} #{model_name} #{year}"

            rescue ActiveRecord::RecordInvalid => e
              puts "Failed to import row: #{row.to_h}. Error: #{e.message}"
            end
          end
        end

        puts "Import completed."

      rescue Errno::ENOENT => e
        puts "File not found: #{e.message}"
      end
    end
  end
end

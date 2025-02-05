class SkipCsvRelatedMigrations < ActiveRecord::Migration[7.1]
  def up
    migrations_to_skip = [
      '20240125133331', # remove_string_from_vehicles
      '20240125133332', # other problematic migrations
    ]

    migrations_to_skip.each do |version|
      if !ActiveRecord::SchemaMigration.where(version: version).exists?
        execute "INSERT INTO schema_migrations (version) VALUES ('#{version}')"
      end
    end
  end

  def down
    migrations_to_skip = [
      '20240125133331',
      '20240125133332',
    ]

    migrations_to_skip.each do |version|
      execute "DELETE FROM schema_migrations WHERE version = '#{version}'"
    end
  end
end

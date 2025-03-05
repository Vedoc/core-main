namespace :db do
  namespace :ultra_seed do
    desc "Ultra fast import vehicles from CSV"
    task vehicles: :environment do
      # Disable SQL logging and optimize DB
      ImportOptimizations.with_import_optimizations do
        Rake::Task["db:fast_seed:vehicles"].invoke
      end
    end
  end
end 
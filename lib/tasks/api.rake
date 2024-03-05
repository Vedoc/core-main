namespace :api do
  namespace :doc do
    doc_path = 'public/docs/v1'

    desc 'Generate API documentation markdown'
    task :md do
      require 'rspec/core/rake_task'

      RSpec::Core::RakeTask.new( :api_spec ) do | t |
        t.pattern = 'spec/requests/v1/'
        t.rspec_opts = '-f Dox::Formatter --order defined --tag dox ' \
                       "--out #{ doc_path }/api_spec.md"
      end

      Rake::Task[ 'api_spec' ].invoke
    end

    task html: :md do
      styles_name = 'custom.css'
      styles_path = "#{ doc_path }/#{ styles_name }"
      output_path = "#{ doc_path }/index.html"

      aglio_cmd = 'aglio -i public/docs/v1/api_spec.md --theme-full-width --theme-style default ' \
                  "--theme-style #{ styles_path } -o #{ output_path }"
      path_cmd = "sed -i -- 's##{ styles_path }##{ styles_name }#g' #{ output_path }"

      `#{ aglio_cmd } && #{ path_cmd }`
    end
  end
end

# Puma can serve each request in a thread from an internal thread pool.
threads_count = ENV.fetch('RAILS_MAX_THREADS') { 5 }
threads threads_count, threads_count

# Bind to a Unix socket instead of a TCP port
bind "unix:///home/ubuntu/core-main/tmp/sockets/puma.sock"

# Specifies the `environment` that Puma will run in.
environment ENV.fetch('RAILS_ENV') { 'production' }

# Define the app block as a Rack application
app do |env|
  Rails.application.call(env)
end

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

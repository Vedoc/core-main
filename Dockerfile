# Stage: Builder
FROM ruby:3.0.2-alpine as Builder

# Copy the master.key file into the container
COPY config/master.key /app/config/master.key

# ...Rest of your builder stage

# Stage Final
FROM ruby:3.0.2-alpine

# Copy app with gems from former build stage
COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app /app /app

# Set user and working directory
USER app
WORKDIR /app

# Set RAILS_MASTER_KEY environment variable
ENV RAILS_MASTER_KEY=$(cat /app/config/master.key)

# Save timestamp of image building
RUN date -u > BUILD_TIME

# Start up
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

# Stage: Builder
FROM ruby:3.3.0-alpine as Builder

# Install Bundler 2.5.6
RUN gem install bundler -v '2.5.6'

ARG FOLDERS_TO_REMOVE
ARG BUNDLE_WITHOUT
ARG RAILS_ENV
ARG NODE_ENV
ARG GIT_CREDENTIALS


ENV BUNDLE_WITHOUT ${BUNDLE_WITHOUT}
ENV RAILS_ENV ${RAILS_ENV}
ENV NODE_ENV ${NODE_ENV}
ENV SECRET_KEY_BASE=foo

RUN apk add --update --no-cache \
    build-base \
    postgresql-dev \
    git \
    nodejs-current \
    yarn \
    tzdata \
    file \
    g++ \
    make \
    libc-dev \
    linux-headers

WORKDIR /app

# Install gems
COPY ./Gemfile* /app/
RUN bundle config frozen false \
 && bundle config "https://github.com/Vedoc/core-main.git" $GIT_CREDENTIALS \
 && bundle install -j4 --retry 3 \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete

# Remove folders not needed in resulting image
RUN rm -rf $FOLDERS_TO_REMOVE

# Initialize PostgreSQL database
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init.sql /docker-entrypoint-initdb.d/

# Copy the startup script and grant executable permission
COPY docker/startup.sh /docker/startup.sh
RUN chmod +x /docker/startup.sh

# Stage Final
FROM ruby:3.3.0-alpine

# Install dependencies
RUN apk add --update --no-cache \
    postgresql-client \
    imagemagick \
    tzdata \
    file \
    git

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app
USER app

# Set working directory
WORKDIR /app

# Copy Gemfile and Gemfile.lock
# COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Copy the rest of the application code
COPY . .

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true

# Expose Puma port
EXPOSE 3000

# Save timestamp of image building
RUN date -u > BUILD_TIME

# Start up
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

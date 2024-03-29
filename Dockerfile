######################
# Stage: Builder
FROM ruby:3.3.0-alpine as Builder

# Install Bundler 2.5.6
RUN gem install bundler -v '2.5.6'

ARG FOLDERS_TO_REMOVE
ARG BUNDLE_WITHOUT
ARG RAILS_ENV
ARG NODE_ENV
ARG GIT_CREDENTIALS

RUN echo "GIT_CREDENTIALS: $GIT_CREDENTIALS"

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
    tzdata

WORKDIR /app

# Install gems
# COPY Gemfile* /app/
# RUN bundle config --global frozen 1 \
#  && bundle config "https://github.com/Vedoc/core-main.git" $GIT_CREDENTIALS \
#  && bundle install -j4 --retry 3 \
#  && rm -rf /usr/local/bundle/cache/*.gem \
#  && find /usr/local/bundle/gems/ -name "*.c" -delete \
#  && find /usr/local/bundle/gems/ -name "*.o" -delete

 # Install gems
COPY Gemfile* /app/
RUN bundle config frozen false \
 && bundle config "https://github.com/Vedoc/core-main.git" $GIT_CREDENTIALS \
 && bundle install -j4 --retry 3 \
 && rm -rf /usr/local/bundle/cache/*.gem \
 && find /usr/local/bundle/gems/ -name "*.c" -delete \
 && find /usr/local/bundle/gems/ -name "*.o" -delete


# Install yarn packages
# COPY package.json yarn.lock .yarnclean /app/
# RUN yarn install

# Add the Rails app
COPY . .

# Copy the master.key file into the container
# COPY config/master.key /app/config/master.key

# COPY .env /app/.env

# Precompile assets
# RUN bundle exec rake assets:precompile

# Remove folders not needed in resulting image
RUN rm -rf $FOLDERS_TO_REMOVE

# Initialize PostgreSQL database
RUN mkdir -p /docker-entrypoint-initdb.d
COPY init.sql /docker-entrypoint-initdb.d/

# Stage Final
FROM ruby:3.3.0-alpine

ARG ADDITIONAL_PACKAGES
ARG EXECJS_RUNTIME

# Add Alpine packages
RUN apk add --update --no-cache \
    postgresql-client \
    imagemagick \
    $ADDITIONAL_PACKAGES \
    tzdata \
    file

# Add user
RUN addgroup -g 1000 -S app \
 && adduser -u 1000 -S app -G app
USER app

# Copy app with gems from former build stage
COPY --from=Builder /usr/local/bundle/ /usr/local/bundle/
COPY --from=Builder --chown=app:app /app /app

# Set Rails env
ENV RAILS_LOG_TO_STDOUT true
ENV RAILS_SERVE_STATIC_FILES true
ENV EXECJS_RUNTIME $EXECJS_RUNTIME

WORKDIR /app

# Expose Puma port
EXPOSE 3000

# Save timestamp of image building
RUN date -u > BUILD_TIME

# Start up
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]

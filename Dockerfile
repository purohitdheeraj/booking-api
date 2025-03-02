# syntax = docker/dockerfile:1

# Ensure the RUBY_VERSION matches your .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.7
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set the working directory for your Rails app
WORKDIR /rails

# Set production environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development

ENV BUNDLE_PATH=/usr/local/bundle

# --- Build Stage ---
FROM base as build

# Install packages required to build native extensions and other dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libvips \
      pkg-config

# Copy Gemfile and Gemfile.lock to install gems
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Remove cached bundle files to reduce image size
RUN rm -rf ~/.bundle/ "$BUNDLE_PATH"/ruby/*/cache "$BUNDLE_PATH"/ruby/*/bundler/gems/*/.git

# Copy the rest of the application code
COPY . .

# Optionally, precompile bootsnap code for faster boot times (disabled here)
# RUN bundle exec bootsnap precompile app/ lib/

# Ensure bin files are executable and in Unix format
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# --- Final Stage ---
FROM base

# Install packages required at runtime (curl, libvips, postgresql-client)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libvips \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy the gems and application code from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user and adjust file permissions for security
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Use the provided entrypoint script to prepare the database
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Expose port 3000 and start the Rails server by default
EXPOSE 3000
CMD ["./bin/rails", "server"]

# syntax = docker/dockerfile:1

# Ensure RUBY_VERSION matches your .ruby-version and Gemfile
ARG RUBY_VERSION=3.3.7
FROM registry.docker.com/library/ruby:$RUBY_VERSION-slim as base

# Set working directory for the Rails app
WORKDIR /rails

# Set production environment variables
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT=development

# --- Build Stage ---
FROM base as build

# Install packages needed for building native extensions and other dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libvips \
      pkg-config

# Explicitly install bundler (this ensures a compatible version is used)
RUN gem install bundler

# Copy Gemfile and Gemfile.lock (ensure Gemfile.lock includes the Linux platform!)
COPY Gemfile Gemfile.lock ./

# Run bundle install with retries and parallel jobs for efficiency
RUN bundle install --jobs 4 --retry 3

# Remove cached bundle files to reduce image size
RUN rm -rf ~/.bundle/ "$BUNDLE_PATH"/ruby/*/cache "$BUNDLE_PATH"/ruby/*/bundler/gems/*/.git

# Copy the rest of the application code
COPY . .

# Adjust bin files to be executable and convert line endings for Linux
RUN chmod +x bin/* && \
    sed -i "s/\r$//g" bin/* && \
    sed -i 's/ruby\.exe$/ruby/' bin/*

# --- Final Stage ---
FROM base

# Install runtime dependencies (curl, libvips, postgresql-client)
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl \
      libvips \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copy gems and application code from the build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Create a non-root user and adjust permissions
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Set the entrypoint and command to start your Rails server
ENTRYPOINT ["/rails/bin/docker-entrypoint"]
EXPOSE 3000
CMD ["./bin/rails", "server"]

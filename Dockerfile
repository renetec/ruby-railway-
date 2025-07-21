FROM ruby:3.2-slim

# Install dependencies
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    npm \
    postgresql-client \
    curl \
    git \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler:2.4.22

# Copy Gemfile and install gems
COPY Gemfile* ./
RUN bundle config set --local deployment false && \
    bundle install

# Copy the rest of the application
COPY . .

# Precompile assets (will be done after app is set up)
# RUN bundle exec rake assets:precompile

# Expose port
EXPOSE 3000

# Start the Rails server
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
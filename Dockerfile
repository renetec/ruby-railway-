FROM ruby:3.2-slim

# Install dependencies including PostgreSQL
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    libyaml-dev \
    nodejs \
    npm \
    postgresql \
    postgresql-contrib \
    postgresql-client \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Setup PostgreSQL
RUN service postgresql start && \
    sudo -u postgres createuser -s root && \
    sudo -u postgres createdb pacomien_development && \
    sudo -u postgres psql -c "ALTER USER root PASSWORD 'password';"

# Install bundler
RUN gem install bundler:2.4.22

# Copy Gemfile and install gems
COPY Gemfile* ./
RUN bundle config set --local deployment false && \
    bundle install

# Copy the rest of the application
COPY . .

# Set database environment variables
ENV PGHOST=localhost
ENV PGUSER=root
ENV PGPASSWORD=password
ENV PGPORT=5432
ENV RAILS_MASTER_KEY=7cfe083fa7bfc2e791dc15a975f359a99510c53e072abf437d3189802281b1d5
ENV RAILS_ENV=development

# Remove credentials to avoid encryption issues
RUN rm -f config/credentials.yml.enc config/master.key

# Create startup script that sets up database and starts server
RUN echo '#!/bin/bash\nservice postgresql start\nsleep 5\nif ! bundle exec rails db:version >/dev/null 2>&1; then\n  bundle exec rails db:create db:migrate\nfi\nbundle exec rails server -b "0.0.0.0"' > /start.sh && \
    chmod +x /start.sh

# Expose port
EXPOSE 3000

# Start the Rails server with PostgreSQL
CMD ["/start.sh"]
# Use official Ruby image
FROM ruby:3.2.2-slim

# Install system dependencies
RUN apt-get update -qq && \
    apt-get install -y build-essential nodejs npm postgresql-client libpq-dev && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /myapp

# Install Rails and PostgreSQL gem
RUN gem install rails pg
RUN rails new . --database=postgresql --skip-git

# Update database.yml to use environment variables
RUN sed -i 's/database: myapp_development/database: <%= ENV["POSTGRES_DB"] || "myapp_development" %>/g' config/database.yml
RUN sed -i 's/username: ~$/username: <%= ENV["POSTGRES_USER"] || "postgres" %>/g' config/database.yml
RUN sed -i 's/password: ~$/password: <%= ENV["POSTGRES_PASSWORD"] || "postgres" %>/g' config/database.yml
RUN sed -i 's/host: ~$/host: <%= ENV["POSTGRES_HOST"] || "db" %>/g' config/database.yml

# Install dependencies
RUN bundle install

# Expose port
EXPOSE 3000

# Start Rails server
CMD ["rails", "server", "-b", "0.0.0.0"]
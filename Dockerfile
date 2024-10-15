# Use an official Ruby runtime as a parent image
FROM ruby:3.0.2

# Set environment variables
ENV RAILS_ENV=development
ENV RAILS_LOG_TO_STDOUT=true

# Install dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs yarn

# Install Yarn (the latest stable version)
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y yarn

# Set the working directory in the container
WORKDIR /app

# Copy the Gemfile and Gemfile.lock to the working directory
COPY Gemfile Gemfile.lock ./

# Install gems
RUN bundle install

# Install Webpacker
RUN bundle exec rails webpacker:install

# Ensure Webpacker is installed and set up
RUN bundle exec rails webpacker:install
RUN bundle exec rails webpacker:binstubs

# Copy the entire app to the working directory
COPY . .


# Precompile assets for production
# RUN bundle exec rake assets:precompile

# Expose port 3000 to the Docker host
EXPOSE 3000

# Set the command to run the Rails server using Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

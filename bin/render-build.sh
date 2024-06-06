#!/usr/bin/env bash
set -o errexit

# Install dependencies
apt-get update -qq
apt-get install -y build-essential libpq-dev imagemagick libheif-dev

# Install Ruby dependencies
bundle install

# Precompile assets and clean up
bundle exec rails assets:precompile
bundle exec rails assets:clean
bundle exec rails db:migrate

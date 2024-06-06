#!/usr/bin/env bash
set -o errexit

# Install necessary dependencies for HEIC support
apt-get update && apt-get install -y libheif-dev

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

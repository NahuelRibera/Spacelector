#!/usr/bin/env bash
set -o errexit

# Install necessary dependencies
apt-get update
apt-get install -y libheif-dev imagemagick

# Configure ImageMagick for HEIC support
if ! grep -q "HEIC" /etc/ImageMagick-6/policy.xml; then
  sed -i '/<\/policymap>/i \
  <policy domain="coder" rights="read|write" pattern="HEIC" />' /etc/ImageMagick-6/policy.xml
fi

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

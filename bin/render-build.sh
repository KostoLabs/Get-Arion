#!/usr/bin/env bash
set -o errexit

echo "Installing gems..."
bundle install

echo "Installing Node modules..."
yarn install --frozen-lockfile

echo "Installing JS dependencies..."
yarn install

echo "Building Tailwind CSS..."
yarn build

echo "Running database migrations..."
bundle exec rails db:prepare

echo "Clobbering old assets..."
bundle exec rails assets:clobber

echo "Precompiling assets for production..."
bundle exec rails assets:precompile

echo "✅ Build complete"

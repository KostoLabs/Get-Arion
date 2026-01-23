source "https://rubygems.org"

ruby "3.4.1"

# Core Rails gems
gem "rails", "~> 7.2.2"
gem "pg", "~> 1.5"
gem "puma", ">= 5.0"

# Assets
gem "propshaft"
gem "importmap-rails"
gem "stimulus-rails"
gem "turbo-rails"

# CSS framework - downgraded to fix compatibility issue
gem "tailwindcss-rails", "~> 2.0.31"

# Job processing
gem "good_job"

# Authentication
gem "bcrypt", "~> 3.1"

# Settings
gem "rails-settings-cached"

# Utilities
gem "bootsnap", require: false
gem "image_processing", ">= 1.2"
gem "pagy"
gem "chartkick"
gem "redcarpet"
gem "inline_svg"
gem "csv"
gem "i18n-js"

# External integrations
gem "stripe"
gem "plaid"
gem "aws-sdk-s3", "~> 1.177.0"
gem "faraday"
gem "faraday-multipart"
gem "faraday-retry"
gem "httparty"
gem "jwt"
gem "octokit"

# Monitoring and analytics
gem "sentry-rails"
gem "sentry-ruby"
gem "logtail-rails"
gem "intercom-rails"

# QR codes and TOTP
gem "rotp", "~> 6.3"
gem "rqrcode", "~> 2.2"

# Git-based gems
gem "hotwire_combobox", git: "https://github.com/josefarias/hotwire_combobox.git", ref: "b827048a8305e1115d5f96931ba1c9750d1e59fc"
gem "lucide-rails", git: "https://github.com/maybe-finance/lucide-rails.git", revision: "272e5fb8418ea458da3995d6abe0ba0ceee9c9f0"

group :development, :test do
  gem "debug"
  gem "dotenv-rails"
  gem "faker"
  gem "brakeman"
  gem "rubocop-rails-omakase"
  gem "erb_lint"
  gem "mocha"
  gem "simplecov"
  gem "vcr"
  gem "webmock"
  gem "capybara"
  gem "selenium-webdriver"
end

group :development do
  gem "web-console"
  gem "hotwire-livereload"
  gem "letter_opener"
  gem "rack-mini-profiler"
  gem "ruby-lsp-rails"
  gem "i18n-tasks"
  gem "benchmark-ips"
  gem "vernier"
  gem "climate_control"
end

group :windows do
  gem "tzinfo-data"
end
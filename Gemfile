source "https://rubygems.org"

# Ruby version (optional but recommended)
# ruby "3.2.2"

# Rails
gem "rails", "~> 8.0.2"

# Core
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "propshaft"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "bootsnap", require: false
gem "faraday", "~> 2.13"

# Optional: Active Model password helpers
# gem "bcrypt", "~> 3.1.7"

# Platforms
gem "tzinfo-data", platforms: %i[windows jruby]

# Rails 8 solid* goodies (if you’re using them)
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Deployment/ops (optional)
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
  gem "rails-controller-testing"
end

group :development do
  gem "web-console"
  gem "listen"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
  gem "mocha"
end

source "https://rubygems.org"

gem "rails", "~> 8.1.2"
gem "propshaft"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

# Authentication
gem "devise"

# Authorization
gem "pundit"

# Multi-tenancy
gem "acts_as_tenant"

# Pagination
gem "pagy"

# Background jobs
gem "sidekiq"
gem "redis"

# Tailwind CSS
gem "tailwindcss-rails"

# PDF generation
gem "prawn"
gem "prawn-table"

# Excel export
gem "caxlsx"
gem "caxlsx_rails"

# Audit logging
gem "paper_trail"

# Charts for survey dashboards (Phase 6)
gem "chartkick"
gem "groupdate"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false

  # Testing
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "shoulda-matchers"
  gem "faker"
end

group :development do
  gem "web-console"
end

group :test do
  gem "capybara"
  gem "selenium-webdriver"
end

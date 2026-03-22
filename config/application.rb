require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module VolunteerHub
  class Application < Rails::Application
    config.load_defaults 8.1
    config.autoload_lib(ignore: %w[assets tasks])

    # Use Sidekiq for background jobs
    config.active_job.queue_adapter = :sidekiq

    # Time zone default
    config.time_zone = "UTC"
    config.active_record.default_timezone = :utc

    # Pagination
    config.action_controller.include_all_helpers = false
  end
end

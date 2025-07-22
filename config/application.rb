require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module TodoApp
  class Application < Rails::Application
    config.load_defaults 7.0
    
    # Time zone
    config.time_zone = 'UTC'
    
    # Generator configurations
    config.generators do |g|
      g.test_framework :rspec
      g.factory_bot true
      g.view_specs false
      g.helper_specs false
      g.routing_specs false
    end
  end
end

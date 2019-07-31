require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Bearpost
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    config.assets.paths << Rails.root.join("vendor", "assets", "general")
    config.assets.paths << Rails.root.join("vendor", "assets", "custom")
    config.assets.paths << Rails.root.join("vendor", "assets", "keen")
    config.assets.paths << Rails.root.join("app",    "assets", "fonts")

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    Rails.configuration.carriers = []

    config.i18n.default_locale = 'pt-BR'
  end
end

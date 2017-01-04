require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AggregateDating
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.assets.paths << Rails.root.join("vendor","assets","bower_components")
    config.assets.paths << Rails.root.join("vendor","assets","bower_components","bootstrap-sass-official","assets","fonts")
    
    config.assets.precompile << %r(.*.(?:eot|svg|ttf|woff|woff2)$)
    config.assets.precompile += %w[ *.png *.jpeg *.jpg *.gif ]
    #oncig.serve_static_assets = true

  end
end

require_relative "version"

module BootswatchRails
  module ActionViewExtensions
    OFFLINE = (Rails.env.development? or Rails.env.test?)

    def bootstrap_js_include_tag(options = {})
      return javascript_include_tag(:bootstrap, options) if !options.delete(:force) and OFFLINE

      bootstrap_js_url = "//maxcdn.bootstrapcdn.com/bootstrap/#{BootswatchRails::BOOTSTRAP}/js/bootstrap.min.js"
      [ javascript_include_tag(bootstrap_js_url, options),
        javascript_tag("window.jQuery.Modal || document.write(unescape('#{javascript_include_tag(:bootstrap, options).gsub('<','%3C')}'))")
      ].join("\n").html_safe
    end
  end

  class Engine < Rails::Engine
    initializer "BootswatchRails" do |app|
      ActiveSupport.on_load(:action_view) do
        include BootswatchRails::ActionViewExtensions
      end
      app.config.assets.precompile += %w(bootstrap.js amelia.css cerulean.css cosmo.css custom.css cyborg.css darkly.css flatly.css journal.css lumen.css paper.css readable.css sandstone.css simplex.css slate.css spacelab.css superhero.css united.css yeti.css)
      app.config.assets.paths << File.expand_path('../../../vendor/assets/fonts', __FILE__)
    end
  end
end


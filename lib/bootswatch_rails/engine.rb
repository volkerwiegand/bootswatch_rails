require_relative "version"

module BootswatchRails
  module ActionViewExtensions
    OFFLINE = (Rails.env.development? or Rails.env.test?)

    def bootswatch_link_tag(theme = nil, options = {})
      theme ||= BootswatchRails::THEMES[BootswatchRails::DEFAULT].to_s
      return stylesheet_link_tag(theme) if !options.delete(:force) and OFFLINE
      bootswatch_url = "//maxcdn.bootstrapcdn.com/bootswatch/#{BootswatchRails::BOOTSWATCH}/#{theme}/bootstrap.min.css"
      fontawesome_url = "//maxcdn.bootstrapcdn.com/font-awesome/#{BootswatchRails::FONT_AWESOME}/css/font-awesome.min.css"
      stylesheet_link_tag(bootswatch_url) + "\n  " + stylesheet_link_tag(fontawesome_url)
    end

    def dataTables_link_tag(options = {})
      return stylesheet_link_tag('jquery.dataTables') if !options.delete(:force) and OFFLINE
      dataTables_url = "//cdn.datatables.net/#{BootswatchRails::DATATABLES}/css/jquery.dataTables.css"
      stylesheet_link_tag(dataTables_url)
    end

    def dataTables_responsive_link_tag(options = {})
      return stylesheet_link_tag('dataTables.responsive') if !options.delete(:force) and OFFLINE
      responsive_url = "//cdn.datatables.net/responsive/#{BootswatchRails::RESPONSIVE}/css/dataTables.responsive.css"
      stylesheet_link_tag(responsive_url)
    end

    def bootstrap_include_tag(options = {})
      return javascript_include_tag(:bootstrap) if !options.delete(:force) and OFFLINE
      bootstrap_url = "//maxcdn.bootstrapcdn.com/bootstrap/#{BootswatchRails::BOOTSTRAP}/js/bootstrap.min.js"
      [ javascript_include_tag(bootstrap_url, options),
        javascript_tag("window.jQuery || document.write(unescape('#{javascript_include_tag(:bootstrap).gsub('<','%3C')}'))")
      ].join("\n").html_safe
    end

    def dataTables_include_tag(options = {})
      return javascript_include_tag('jquery.dataTables') if !options.delete(:force) and OFFLINE
      dataTables_url = "//cdn.datatables.net/#{BootswatchRails::DATATABLES}/js/jquery.dataTables.js"
      [ javascript_include_tag(dataTables_url, options),
        javascript_tag("window.jQuery || document.write(unescape('#{javascript_include_tag('jquery.dataTables').gsub('<','%3C')}'))")
      ].join("\n").html_safe
    end

    def dataTables_responsive_include_tag(options = {})
      return javascript_include_tag('dataTables.responsive') if !options.delete(:force) and OFFLINE
      responsive_url = "//cdn.datatables.net/responsive/#{BootswatchRails::RESPONSIVE}/js/dataTables.responsive.js"
      [ javascript_include_tag(responsive_url, options),
        javascript_tag("window.jQuery || document.write(unescape('#{javascript_include_tag('dataTables.responsive').gsub('<','%3C')}'))")
      ].join("\n").html_safe
    end
  end

  class Engine < Rails::Engine
    initializer "BootswatchRails" do |app|
      ActiveSupport.on_load(:action_view) do
        include BootswatchRails::ActionViewExtensions
      end
      app.config.assets.precompile += %w(jquery.dataTables.css dataTables.responsive.css cerulean.css cosmo.css custom.css cyborg.css darkly.css flatly.css journal.css lumen.css paper.css readable.css sandstone.css simplex.css slate.css spacelab.css superhero.css united.css yeti.css)
      app.config.assets.paths << File.expand_path('../../../vendor/assets/fonts', __FILE__)
    end
  end
end


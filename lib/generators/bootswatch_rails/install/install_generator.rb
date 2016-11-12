module BootswatchRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Setup application to use bootswatch.com"
      class_option :turbolinks, type: :boolean, default: false,
               desc: 'Activate turbolinks (off by default)'
      class_option :ui, type: :boolean, default: false,
               desc: 'Include jQuery-ui (requires jquery-ui-rails gem)'
      class_option :dt, type: :boolean, default: false,
               desc: 'Include the jQuery DataTables plugin'
      class_option :cdn, type: :string, default: 'none',
               banner: 'none, google, microsoft, jquery or yandex',
               desc: 'Use CDN (requires jquery[-ui]-rails-cdn gems)'
      source_root File.expand_path("../templates", __FILE__)

      def update_application_controller
        file = "app/controllers/application_controller.rb"
        inject_into_file file, "\n\n  private", after: /protect_from_forgery.*$/

        lines = [
          "",
          "  def default_theme",
          "    BootswatchRails::THEMES[BootswatchRails::DEFAULT].to_s",
          "  end",
          "  helper_method :default_theme",
          "",
          "  def current_theme",
          "    @current_theme = current_user.theme if logged_in?",
          "    @current_theme ||= default_theme",
          "  end",
          "  helper_method :current_theme",
          ""
        ]
        inject_into_file file, lines.join("\n"), before: /^end$/
      end

      def update_application_js
        return if options.cdn?
        file = "app/assets/javascripts/application.js"
        inject_into_file file, after: /require jquery_ujs$/ do
          "\n//= require bootstrap"
        end
        if options.ui?
          inject_into_file file, after: /require jquery$/ do
            "\n//= require jquery-ui"
          end
        end
        if options.dt?
          inject_into_file file, before: /^\/\/= require_tree.*$/ do
            "//= require jquery.dataTables\n" +
            "//= require dataTables.responsive\n"
          end
        end
      end

      #def copy_application_js
      #  file = "app/assets/javascripts/application.js"
      #  remove_file file
      #  template "application.js", file
      #end

      def setup_assets_precompile
        return unless options.cdn?
        initializer "bootswatch_assets.rb" do
          assets  = "jquery.js"
          assets += " jquery-ui.js" if options.ui?
          assets += " jquery.dataTables.js dataTables.responsive.js" if options.dt?
          assets += " bootstrap.js"
          "Rails.application.config.assets.precompile += %w( #{assets} )"
        end
      end

      def copy_directories
        directory "app", force: true
        directory "config"
        directory "lib", force: true
      end

      def setup_head
        template "head.html.erb", "app/views/layouts/_head.html.erb"
      end

      protected

      def turbolinks
        options.turbolinks? ? ", 'data-turbolinks-track' => true" : ""
      end
    end
  end
end

# vim: set expandtab softtabstop=2 shiftwidth=2 autoindent :

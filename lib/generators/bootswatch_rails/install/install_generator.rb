module BootswatchRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Setup application to use bootswatch.com"
      class_option :turbolinks, type: :boolean, default: false,
               desc: 'Activate turbolinks (off by default)'
      class_option :ui, type: :boolean, default: false,
               desc: 'Include jQuery-ui (requires jquery-ui gem)'
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
          "    @current_theme = current_user.theme if current_user.present?",
          "    @current_theme ||= default_theme",
          "  end",
          "  helper_method :current_theme",
          ""
        ]
        inject_into_file file, lines.join("\n"), before: /^end$/
      end

      def copy_directories
        directory "app", force: true
        directory "config"
        directory "lib", force: true
      end

      def setup_head
        template "head.html.erb", "app/views/layouts/_head.html.erb"
      end

      def update_application_html
        appjs = "app/assets/javascripts/application.js"
        unless options.turbolinks?
          gsub_file appjs, /^\/\/= require turbolinks\s/, ""
        end
        if options.ui? and !options.cdn?
          inject_into_file appjs, after: /= require jquery$/ do
            "\n//= require jquery-ui"
          end
        end
        if options.cdn?
          gsub_file appjs, /^\/\/= require jquery\s/, ""
        end
      end

      protected

      def turbolinks
        options.turbolinks? ? ", 'data-turbolinks-track' => true" : ""
      end
    end
  end
end

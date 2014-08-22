module BootswatchRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Setup application to use bootswatch.com"
      class_option :turbolinks, type: :boolean, default: false,
               desc: 'Activate turbolinks (off by default)'
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
        template "head.html.erb", "app/views/layouts/_head.html.erb"
      end
      
      def remove_turbolinks
        return if options.turbolinks?
        comment_lines "Gemfile", /gem 'turbolinks/
        file = "app/assets/javascripts/application.js"
        gsub_file file, /^\/\/= require turbolinks\s/, ""
        file = "app/views/layouts/_head.html.erb"
        gsub_file file, /, 'data-turbolinks-track' => true/, ""
      end
    end
  end
end

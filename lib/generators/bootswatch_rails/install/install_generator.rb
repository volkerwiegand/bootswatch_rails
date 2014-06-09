module BootswatchRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Setup application to use bootswatch.com"
      class_option :bootstrap, type: :boolean, default: true,
               desc: 'Add bootstrap to application.js'
      source_root File.expand_path("../templates", __FILE__)
      
      def update_javascripts
        return unless options.bootstrap?
        inside "app/assets/javascripts" do
          inject_into_file "application.js", after: /require jquery_ujs$/ do
            "\n//= require bootstrap"
          end
        end
      end
      
      def update_application_controller
        inside "app/controllers" do
          file = "application_controller.rb"
          inject_into_file file, after: /protect_from_forgery.*$/ do
            "\n\n  private"
          end
          lines = [
            "",
            "  def default_theme",
            "    BootswatchRails::THEMES[BootswatchRails::DEFAULT].to_s",
            "  end",
            "  helper_method :default_theme",
            "",
            "  def current_theme",
            "    @current_theme = current_user.theme if user_signed_in?",
            "    @current_theme ||= default_theme",
            "  end",
            "  helper_method :current_theme",
            ""
          ]
          inject_into_file file, before: /^end$/ do
            lines.join("\n")
          end
        end
      end
      
      def copy_directories
        directory "app", force: true
        directory "config"
        directory "lib", force: true
      end
    end
  end
end


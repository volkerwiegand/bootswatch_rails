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

      def copy_application_js
        template "application.js", "app/assets/javascripts/application.js"
      end

      def setup_assets_precompile
        return unless options.cdn?
        initializer "bootswatch_assets.rb" do
          assets  = "jquery.js"
          assets += " jquery-ui.js" if options.ui?
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

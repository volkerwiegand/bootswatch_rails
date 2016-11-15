module BootswatchRails
  module Generators
    class InstallGenerator < Rails::Generators::Base
      desc "Setup application to use bootswatch.com"
      class_option :turbolinks, type: :boolean, default: false,
               desc: 'Activate turbolinks (off by default)'
      class_option :ui, type: :boolean, default: false,
               desc: 'Include jQuery-ui (requires jquery-ui-rails gem)'
      class_option :dt, type: :boolean, default: false,
               desc: 'Include the jQuery DataTables plugin (and responsive)'
      class_option :cdn, type: :string, default: 'none',
               banner: 'none/google/microsoft/jquery/yandex',
               desc: 'Use CDN (requires jquery[-ui]-rails-cdn gems)'
      class_option :auth, type: :string, default: 'sorcery',
               banner: 'none/devise resource (e.g. user)/sorcery',
               desc: 'Setup some authentication logic for sorcery or devise'
      class_option :layout, type: :string, default: 'custom',
               banner: 'custom(just div.row)/single(col-lg-12)/sidebar(content_for)',
               desc: 'Install default application layout'
      source_root File.expand_path("../templates", __FILE__)

      def update_application_controller
        file = "app/controllers/application_controller.rb"
        if options.auth == "none"
          lines = [
            ""
          ]
        elsif options.auth == "sorcery"
          lines = [
            "",
            "  before_action :require_login"
          ]
        else
          lines = [
            "",
            "  before_action :authenticate_#{options.auth}!"
          ]
        end
        lines += [
          "",
          "  private",
          "",
          "  def default_theme",
          "    BootswatchRails::THEMES[BootswatchRails::DEFAULT].to_s",
          "  end",
          "  helper_method :default_theme"
        ]
        if options.auth != "none"
          lines += [
            "",
            "  def current_theme",
            "    @current_theme = current_#{auth_resource}.theme if #{auth_check}",
            "    @current_theme ||= default_theme",
            "  end",
            "  helper_method :current_theme"
          ]
        end
        if options.auth == "sorcery"
          lines += [
            "",
            "  def not_authenticated",
            "    redirect_to login_path, alert: t('sorcery.required')",
            "  end"
          ]
        elsif options.auth != "none"
          lines += [
            "",
            "  def after_sign_in_path_for(resource)",
            "    session['#{auth_resource}_return_to'] || root_path",
            "  end"
          ]
        end
        inject_into_file file, lines.join("\n"), after: /protect_from_forgery.*$/
      end

      def update_application_js
        file = "app/assets/javascripts/application.js"
        unless options.turbolinks?
          gsub_file file, /\/\/= require turbolinks\n/, ''
        end
        if options.cdn == "none"
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
      end

      def update_application_css
        if options.cdn == "none"
          file = "app/assets/stylesheets/application.css"
          if options.dt?
            inject_into_file file, before: /^.*require_self$/ do
              " *= jquery.dataTables\n" +
              " *= responsive.dataTables\n"
            end
          end
        end
      end

      def setup_assets_precompile
        return if options.cdn == "none"
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

      def setup_layout
        file = "app/views/layouts/application.html.erb"
        remove_file file
        template "#{options.layout}.html.erb", file
        if options.auth != "none"
          template "theme.html.erb", "app/views/layouts/_theme.html.erb"
        end
      end

      protected

      def auth_resource
        options.auth == "sorcery" ?  "user" : options.auth
      end

      def auth_check
        options.auth == "sorcery" ? "logged_in?" : "#{options.auth}_signed_in?"
      end

      def turbolinks
        options.turbolinks? ? ", 'data-turbolinks-track' => true" : ""
      end
    end
  end
end

# vim: set expandtab softtabstop=2 shiftwidth=2 autoindent :

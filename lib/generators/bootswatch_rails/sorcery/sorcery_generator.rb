require 'rails/generators/active_record'

module BootswatchRails
  USER_STATUS = %w(guest member admin sysadm)

  module Generators
    class SorceryGenerator < ActiveRecord::Generators::Base
      desc "Install model, views and controller for Sorcery."
      argument :name, type: :string, default: "user",
               banner: "user model (default 'user')"
      class_option :user_activation, type: :boolean, default: false,
               desc: 'User activation by email with optional success email'
      class_option :reset_password, type: :boolean, default: false,
               desc: 'Reset password with email verification'
      class_option :remember_me, type: :boolean, default: false,
               desc: 'Remember me with configurable expiration'
      class_option :session_timeout, type: :boolean, default: false,
               desc: 'Configurable session timeout'
      class_option :brute_force_protection, type: :boolean, default: false,
               desc: 'Brute force login hammering protection'
      class_option :http_basic_auth, type: :boolean, default: false,
               desc: 'A before filter for requesting authentication with HTTP Basic'
      class_option :activity_logging, type: :boolean, default: false,
               desc: 'Automatic logging of last login, logout and activity'
      class_option :external, type: :boolean, default: false,
               desc: 'OAuth1 and OAuth2 support (Twitter, Facebook, etc.)'
      class_option :layout, type: :string, default: 'centered',
               desc: 'Layout to be used for rendering login.html.erb'
      source_root File.expand_path("../templates", __FILE__)
      
      def add_migration
        migration_template "user_migration.rb", "db/migrate/create_#{table_name}.rb"
      end

      def add_model
        template "user_model.rb", "app/models/#{name}.rb"
      end

      def add_mailer
        return unless reset_password?
        template "user_mailer.rb", "app/mailers/#{name}_mailer.rb"
        template "reset_password_email.html.erb", "app/views/#{name}_mailer/reset_password_email.html.erb"
      end

      def add_controller
        template "users_controller.rb", "app/controllers/#{table_name}_controller.rb"
      end

      def add_views
        views  = %w[edit _form index log_in new show]
        views += %w[password change] if reset_password?
        views.each do |view|
          template "#{view}.html.erb", "app/views/#{table_name}/#{view}.html.erb"
        end
      end

      def add_routes
        lines = [
          "resources :#{table_name} do",
          "    collection do",
          "      get   'log_in'",
          "      post  'access'",
          "      get   'log_out'"
        ]
        lines << [
          "      get   'password'",
          "      post  'reset'"
        ] if reset_password?
        lines << [
          "    end"
        ]
        lines << [
          "    member do",
          "      get   'change'",
          "      patch 'refresh'",
          "      put   'refresh'",
          "    end"
        ] if reset_password?
        lines << [
          "  end",
          "get '/login'  => '#{table_name}#log_in',  as: :login",
          "get '/logout' => '#{table_name}#log_out', as: :logout",
          ""
        ]
        route lines.join("\n")
      end

      def add_initializer
        template "initializer.rb", "config/initializers/sorcery.rb"
      end

      def add_locales
        %w[de].each do |locale|
          template "sorcery.#{locale}.yml", "config/locales/sorcery.#{locale}.yml"
        end
      end

      def update_application_controller
        file = "app/controllers/application_controller.rb"
        inject_into_class file, "ApplicationController", "  before_filter :require_login\n\n"
        inject_into_file file, "\n\n  private", after: /protect_from_forgery.*$/
        lines = [
          "",
          "  def not_authenticated",
          "    redirect_to login_path, alert: t('sorcery.required')",
          "  end",
          ""
        ]
        inject_into_file file, lines.join("\n"), before: /^end$/
      end

      protected

      def user_activation?
        options.user_activation?
      end

      def reset_password?
        options.reset_password?
      end

      def remember_me?
        options.remember_me?
      end

      def session_timeout?
        options.session_timeout?
      end

      def brute_force_protection?
        options.brute_force_protection?
      end

      def http_basic_auth?
        options.http_basic_auth?
      end

      def activity_logging?
        options.activity_logging?
      end

      def external?
        options.external?
      end

      def submodules
        modules = []
        modules << ":user_activation"        if user_activation?
        modules << ":reset_password"         if reset_password?
        modules << ":remember_me"            if remember_me?
        modules << ":session_timeout"        if session_timeout?
        modules << ":brute_force_protection" if brute_force_protection?
        modules << ":http_basic_auth"        if http_basic_auth?
        modules << ":activity_logging"       if activity_logging?
        modules << ":external"               if external?
        modules.join(', ')
      end

      def layout
        options.layout
      end

      def migration_name
        "create_#{table_name}"
      end

      def mailer_name
        "#{name}_mailer"
      end

      def controller_name
        "#{table_name}_controller"
      end

      def whitelist
        ":email, :name, :active, :status, :password, :password_confirmation, :theme"
      end
    end
  end
end

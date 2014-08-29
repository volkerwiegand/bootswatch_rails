require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class SorceryGenerator < ActiveRecord::Generators::Base
      desc "Install authentication (with Sorcery) and (optional) authorization."
      argument :name, type: :string, default: "user",
               banner: "user model (default 'user')"
      class_option :picture, type: :boolean, default: false,
               desc: 'Add picture to user (needs carrierwave)'
      class_option :authorization, type: :boolean, default: true,
               desc: 'Add dynamic athorization on top of authentication'
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
      
      def add_migrations
        migration_template "user_migration.rb", "db/migrate/create_#{table_name}.rb"
        return unless options.authorization?
        migration_template "role_migration.rb",       "db/migrate/create_roles.rb"
        migration_template "assignment_migration.rb", "db/migrate/create_assignments.rb"
        migration_template "ability_migration.rb",    "db/migrate/create_abilities.rb"
      end

      def add_models
        template "user_model.rb", "app/models/#{name}.rb"
        return unless options.authorization?
        template "role_model.rb",       "app/models/role.rb"
        template "assignment_model.rb", "app/models/assignment.rb"
        template "ability_model.rb",    "app/models/ability.rb"
      end

      def add_mailer
        return unless reset_password?
        template "user_mailer.rb", "app/mailers/#{mailer_name}.rb"
        template "reset_password_email.html.erb", "app/views/#{mailer_name}/reset_password_email.html.erb"
      end

      def add_controllers
        template "users_controller.rb", "app/controllers/#{table_name}_controller.rb"
        return unless authorization?
        # template "roles_controller.rb",       "app/controllers/roles_controller.rb"
        # template "assignments_controller.rb", "app/controllers/assignment_controller.rb"
        # template "abilities_controller.rb",   "app/controllers/abilities_controller.rb"
      end

      def add_views
        views  = %w[edit _form index log_in new show]
        views += %w[password change] if reset_password?
        views.each do |view|
          template "#{view}.html.erb", "app/views/#{table_name}/#{view}.html.erb"
        end
        return unless options.authorization?
        # TODO
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
          "  get '/login'  => '#{table_name}#log_in',  as: :login,  format: false",
          "  get '/logout' => '#{table_name}#log_out', as: :logout, format: false",
          ""
        ]
        lines << [
          "",
          "resources :roles",
          "resources :assignments"
          "resources :abilities",
          ""
        ] if options.authorization?
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

      def has_picture?
        options.picture?
      end

      def authorization?
        options.authorization?
      end

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
        text = ":email, :name, :phone, :comment, :theme, " +
        ":active, :sysadm, :password, :password_confirmation"
        text += ", :picture, :picture_cache" if options.picture?
      end
    end
  end
end

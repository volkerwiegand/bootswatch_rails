require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class CreatedByGenerator < ActiveRecord::Generators::Base
      desc "Add created_by and updated_by to resource"
      argument :name, type: :string,
               desc: "The resource to be updated"
      argument :user, type: :string, default: "user",
               banner: "name of the user model"
      class_option :migration, type: :boolean, default: false,
               desc: 'Create a migration for added attributes'
      source_root File.expand_path('../templates', __FILE__)
      
      def add_migration
        return unless options.migration?
        migration_template 'created_by_migration.rb', "db/migrate/#{migration_name}.rb"
      end
      
      def add_helper
        template "created_by_helper.rb", "app/helpers/created_by_helper.rb"
      end
      
      def update_controller
        file = "app/controllers/#{table_name}_controller.rb"
        curr = "current_#{user}"
        inject_into_file file, after: /def update$/ do
          "\n    @#{name}.updated_by = #{curr} ? #{curr}.id : nil"
        end
        inject_into_file file, after: /@#{name} = #{class_name}\.new\(#{name}_params\)$/ do
          "\n    @#{name}.created_by = #{curr} ? #{curr}.id : nil" +
          "\n    @#{name}.updated_by = #{curr} ? #{curr}.id : nil"
        end
      end
      
      protected
      
      def migration_name
        "add_created_by_to_#{table_name}"
      end
    end
  end
end

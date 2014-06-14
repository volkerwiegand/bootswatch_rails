require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class CarrierwaveGenerator < ActiveRecord::Generators::Base
      desc "Add carrierwave uploader to resource"
      argument :name, type: :string,
               desc: "The object that will have an attachment"
      argument :column, type: :string,
               desc: 'The column name for the attachment'
      class_option :uploader, type: :boolean, default: true,
               desc: 'Add an appropriate uploader'
      class_option :migration, type: :boolean, default: false,
               desc: 'Create a migration for added attributes'
      class_option :permit, type: :boolean, default: false,
               desc: 'Allow mass assignment for added attributes'
      class_option :before, type: :boolean, default: false,
               desc: 'Add a line before generated text in model'
      class_option :after, type: :boolean, default: false,
               desc: 'Add a line after generated text in model'
      source_root File.expand_path('../templates', __FILE__)
      
      def add_uploader
        if picture?
          template "picture_uploader.rb", "app/uploaders/#{column}_uploader.rb"
        elsif document?
          template "document_uploader.rb", "app/uploaders/#{column}_uploader.rb"
        else
          run "rails generate uploader #{column.camelize}"
        end
      end
      
      def add_migration
        return unless options.migration?
        migration_template "carrierwave_migration.rb", "db/migrate/#{migration_name}.rb"
      end
      
      def add_to_model
        inject_into_class "app/models/#{name}.rb", class_name do
          text = options.before? ? "\n" : ""
          text << "  mount_uploader :#{column}, #{column.camelize}Uploader\n"
          text << "\n" if options.after?
          text
        end
      end
      
      def add_to_permit
        file = "app/controllers/#{table_name}_controller.rb"
        if options.permit?
          gsub_file file, /(permit\(.*)\)/, "\\1, :#{column})"
          # Special case: no previous permit
          gsub_file file, /^(\s*params)\[:#{name}\]$/, "\\1.require(:#{name}).permit(:#{column})"
        end
        gsub_file file, /(permit.*)(:#{column})(.*)/, "\\1\\2, :#{column}_cache, :remove_#{column}\\3"
      end
      
      protected
      
      def picture?
        column.include?("picture")
      end
      
      def document?
        column.include?("document")
      end
      
      def migration_name
        "add_#{column}_to_#{table_name}"
      end
    end
  end
end


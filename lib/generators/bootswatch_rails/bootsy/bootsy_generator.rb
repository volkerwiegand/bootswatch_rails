require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class BootsyGenerator < ActiveRecord::Generators::Base
      desc "Turn text_area(s) into bootsy_area(s)"
      argument :name, type: :string,
               desc: "The resource that will have bootsy_areas"
      argument :columns, type: :array, banner: "COLUMN [...]",
               desc: "The names of the text attributes to be converted"
      class_option :before, type: :boolean, default: false,
               desc: 'Add a line before generated text in model'
      class_option :after, type: :boolean, default: false,
               desc: 'Add a line after generated text in model'
      class_option :permit, type: :boolean, default: true,
               desc: 'Allow mass assignment for bootsy_image_gallery_id'
      
      def add_to_model
        inject_into_class "app/models/#{name}.rb", class_name do
          text = options.before? ? "\n" : ""
          text << "  include Bootsy::Container\n"
          text << "\n" if options.after?
          text
        end
      end
      
      def add_to_permit
        return unless options.permit?
        text = ":bootsy_image_gallery_id"
        file = "app/controllers/#{table_name}_controller.rb"
        gsub_file file, /(permit\(.*)\)/, "\\1, #{text})"
        # Special case: no previous permit
        gsub_file file, /^(\s*params)\[:#{name}\]$/, "\\1.require(:#{name}).permit(#{text})"
      end
      
      def add_to_view
        file = "app/views/#{table_name}/_form.html.erb"
        columns.each do |column|
          gsub_file file, /(input :#{column}) /, "\\1, as: :bootsy, input_html: { rows: 10 } "
        end
      end
      
    end
  end
end


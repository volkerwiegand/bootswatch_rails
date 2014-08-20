require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class CleditorGenerator < ActiveRecord::Generators::Base
      desc "Turn text_area(s) into rich edit fields with CLEditor"
      argument :name, type: :string,
               desc: "The resource with textareas to be enhanced"
      argument :columns, type: :array, banner: "COLUMN [...]",
               desc: "The names of the textarea columns"
      source_root File.expand_path('../templates', __FILE__)
      
      def add_to_assets
        file = "app/assets/javascripts/application.js"
        inject_into_file file, "\n//= require jquery.cleditor", after: /require jquery_ujs$/
        file = "app/assets/stylesheets/application.css"
        inject_into_file file, " *= require jquery.cleditor\n", before: /^.*require_self/
      end
      
      def add_to_view
        file = "app/views/#{table_name}/index.html.erb"
        columns.each do |column|
          gsub_file file, /(#{name}\.#{column})/, "raw(\\1)"
        end
        file = "app/views/#{table_name}/show.html.erb"
        columns.each do |column|
          gsub_file file, /(@#{name}\.#{column})/, "raw(\\1)"
        end
        file = "app/views/#{table_name}/_form.html.erb"
        columns.each do |column|
          gsub_file file, /(:#{column}) /, "\\1, input_html: { class: 'cleditor' } "
        end
      end
    end
  end
end


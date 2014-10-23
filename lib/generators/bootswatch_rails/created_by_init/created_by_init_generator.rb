module BootswatchRails
  module Generators
    class CreatedByInitGenerator < Rails::Generators::Base
      desc "Setup the created_by helper"
      class_option :user, type: :string, default: "user",
               banner: "name of the user model"
      source_root File.expand_path('../templates', __FILE__)
      
      def add_helper
        template "created_by_helper.rb", "app/helpers/created_by_helper.rb"
      end
    end
  end
end

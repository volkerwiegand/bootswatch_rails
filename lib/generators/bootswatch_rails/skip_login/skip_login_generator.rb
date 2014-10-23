require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class SkipLoginGenerator < ActiveRecord::Generators::Base
      desc "Add skip_require_login to resource"
      argument :name, type: :string,
               desc: "The resource to be updated"
      argument :actions, type: :array,
               banner: "the actions to be publicly available"

      def update_controller
        file = "app/controllers/#{table_name}_controller.rb"
        list = actions.map{|a| ":#{a}"}.join(', ')
        inject_into_file file, after: /before_action :set.*$/ do
          "\n  skip_before_action :require_login, only: [#{list}]"
        end
      end
    end
  end
end

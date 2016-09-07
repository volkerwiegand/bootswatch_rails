require 'rails/generators/active_record'

module BootswatchRails
  module Generators
    class SkipLoginGenerator < ActiveRecord::Generators::Base
      desc "Add skip_require_login to resource"
      argument :name, type: :string,
               desc: "The resource to be updated"
      argument :actions, type: :array,
               banner: "the actions to be publicly available or 'all'"

      def update_controller
        file = "app/controllers/#{table_name}_controller.rb"
        if actions.include?('all')
          text = ""
        else
          list = actions.map{|a| ":#{a}"}.join(', ')
          text = ", only: [#{list}]"
        end
        inject_into_file file, after: /before_action :set.*$/ do
          "\n  skip_before_action :require_login#{text}"
        end
      end
    end
  end
end

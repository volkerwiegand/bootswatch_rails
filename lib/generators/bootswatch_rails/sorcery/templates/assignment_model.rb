class Assignment < ActiveRecord::Base
  belongs_to :<%= name %>
  belongs_to :role
end

class Role < ActiveRecord::Base
  has_many :assignments
  has_many :<%= table_name %>, through: :assignments
  has_many :abilities
end

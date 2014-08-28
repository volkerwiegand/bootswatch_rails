class <%= migration_name(ability).camelize %> < ActiveRecord::Migration
  def change
    create_table :<%= ability.pluralize %> do |t|
      t.string :resource, null: false
      

      t.timestamps
    end

    add_index :<%= table_name %>, :resource, unique: true
  end
end

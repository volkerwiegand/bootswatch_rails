class <%= migration_name(role).camelize %> < ActiveRecord::Migration
  def change
    create_table :<%= role.pluralize %> do |t|
      t.string :name, null: false

      t.timestamps
    end

    add_index :<%= role.pluralize %>, :name, unique: true

    create_table :<%= member_migration %>, :id => false do |t|
      t.integer :<%= name %>_id, :null => false
      t.integer :<%= role %>_id, :null => false
    end

    add_index :<%= member_migration %>, :<%= name %>_id
    add_index :<%= member_migration %>, :<%= role %>_id
  end
end

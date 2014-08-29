class CreateAssignments < ActiveRecord::Migration
  def change
    create_table :assignments do |t|
      t.belongs_to :<%= name %>, index: true
      t.belongs_to :role, index: true

      t.timestamps
    end
end

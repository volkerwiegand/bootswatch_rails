class CreateAbilities < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.belongs_to :role, index: true
      t.string :resource, null: false
      t.boolean :create_new, default: false
      t.boolean :read_own,   default: false
      t.boolean :read_any,   default: false
      t.boolean :update_own, default: false
      t.boolean :update_any, default: false
      t.boolean :delete_own, default: false
      t.boolean :delete_any, default: false
      t.boolean :user1_own,  default: false
      t.boolean :user1_any,  default: false
      t.string  :user1_name
      t.boolean :user2_own,  default: false
      t.boolean :user2_any,  default: false
      t.string  :user2_name
      t.boolean :user3_own,  default: false
      t.boolean :user3_any,  default: false
      t.string  :user3_name

      t.timestamps
    end

    add_index :abilities, :resource, unique: true
  end
end

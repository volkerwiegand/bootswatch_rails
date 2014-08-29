class CreateAbilities < ActiveRecord::Migration
  def change
    create_table :abilities do |t|
      t.string :resource, null: false
      t.boolean :create, default: false
      t.boolean :read,   default: false
      t.boolean :update, default: false
      t.boolean :delete, default: false
      t.boolean :user1,  default: false
      t.boolean :user2,  default: false
      t.boolean :user3,  default: false

      t.timestamps
    end

    add_index :abilities, :resource, unique: true
  end
end

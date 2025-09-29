class AddRoleEnumToUsers < ActiveRecord::Migration[7.1]
  def up
    change_table :users, bulk: true do |t|
      t.remove  :role
      t.integer :role, null: false, default: 1
      t.index   :role
    end
  end

  def down
    change_table :users, bulk: true do |t|
      t.remove_index :role
      t.remove       :role
      t.string       :role, null: false, default: 'admin'
    end
  end
end

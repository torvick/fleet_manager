class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :users do |t|
      t.string :email,           null: false
      t.string :password_digest, null: false
      t.string :role,            null: false, default: 'admin'
      t.timestamps
    end

    add_index :users, 'LOWER(email)', unique: true, name: 'index_users_on_lower_email'
  end
end

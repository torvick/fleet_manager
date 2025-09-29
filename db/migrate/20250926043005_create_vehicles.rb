class CreateVehicles < ActiveRecord::Migration[7.1]
  def change
    create_table :vehicles do |t|
      t.string  :vin,   null: false
      t.string  :plate, null: false
      t.string  :brand, null: false
      t.string  :model, null: false
      t.integer :year,  null: false
      t.integer :status, null: false, default: 0
      t.timestamps
    end

    add_index :vehicles, 'LOWER(vin)',   unique: true, name: 'index_vehicles_on_lower_vin'
    add_index :vehicles, 'LOWER(plate)', unique: true, name: 'index_vehicles_on_lower_plate'
  end
end

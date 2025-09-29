class CreateMaintenanceServices < ActiveRecord::Migration[7.1]
  def change
    create_table :maintenance_services do |t|
      t.references :vehicle, null: false, foreign_key: true
      t.string     :description, null: false
      t.integer    :status, null: false, default: 0
      t.date       :date, null: false
      t.integer    :cost_cents, null: false, default: 0
      t.integer    :priority, null: false, default: 1
      t.datetime   :completed_at
      t.timestamps
    end

    add_index :maintenance_services, :date
    add_index :maintenance_services, :status
  end
end

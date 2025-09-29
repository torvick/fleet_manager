class ChangeCostCentsToBigintOnMaintenanceServices < ActiveRecord::Migration[7.1]
  def up
    change_column :maintenance_services, :cost_cents, :bigint, null: false, default: 0
  end

  def down
    change_column :maintenance_services, :cost_cents, :integer, null: false, default: 0
  end
end

class AddDiscardedAtToVehicles < ActiveRecord::Migration[7.1]
  def change
    add_column :vehicles, :discarded_at, :datetime
    add_index :vehicles, :discarded_at
  end
end

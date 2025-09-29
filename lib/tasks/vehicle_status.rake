namespace :vehicle_status do
  desc 'Recalcula status para todos los vehículos'
  task recalc_all: :environment do
    Vehicle.find_each do |v|
      VehicleStatusRefresher.call(v.id)
      puts "OK: Vehicle ##{v.id} -> #{v.reload.status}"
    end
  end
end

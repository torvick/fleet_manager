class VehicleStatusRefresher
  def self.call(vehicle_id)
    new(vehicle_id).call
  end

  def initialize(vehicle_id)
    @vehicle_id = vehicle_id
  end

  def call
    vehicle    = Vehicle.find(@vehicle_id)
    new_status = compute_status_for(vehicle)
    return vehicle if vehicle.status.to_sym == new_status

    vehicle.update!(status: new_status) # usa validaciones/callbacks; evita update_column
    vehicle
  end

  private

  def compute_status_for(vehicle)
    open_exists = vehicle.maintenance_services.exists?(status: %i[pending in_progress])
    return :in_maintenance if open_exists

    vehicle.status_inactive? ? :inactive : :active
  end
end

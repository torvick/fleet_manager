class VehicleSerializer < ApplicationSerializer
  attributes :id, :vin, :plate, :brand, :model, :year, :status, :created_at, :updated_at
end

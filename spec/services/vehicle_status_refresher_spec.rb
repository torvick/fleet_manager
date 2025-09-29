require 'rails_helper'

RSpec.describe VehicleStatusRefresher do
  let!(:vehicle) { create(:vehicle, status: :active) }

  it 'pone in_maintenance si hay servicios abiertos' do
    create(:maintenance_service, vehicle: vehicle, status: :pending, date: Time.zone.today, cost_cents: 1000,
                                 priority: :low)
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('in_maintenance')
  end

  it 'pone active si no hay abiertos (y no estaba inactive)' do
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('active')
  end

  it 'mantiene inactive si no hay abiertos' do
    vehicle.update!(status: :inactive)
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('inactive')
  end
end

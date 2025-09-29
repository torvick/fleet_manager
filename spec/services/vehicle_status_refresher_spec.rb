require 'rails_helper'

RSpec.describe VehicleStatusRefresher do
  let!(:vehicle) { create(:vehicle, status: :active) }

  it 'sets in_maintenance if there are open services' do
    create(:maintenance_service, vehicle: vehicle, status: :pending, date: Time.zone.today,
                                 cost_cents: 1000, priority: :low)
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('in_maintenance')
  end

  it 'sets active if there are no open services (and was not inactive)' do
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('active')
  end

  it 'keeps inactive if there are no open services' do
    vehicle.update!(status: :inactive)
    described_class.call(vehicle.id)
    expect(vehicle.reload.status).to eq('inactive')
  end
end

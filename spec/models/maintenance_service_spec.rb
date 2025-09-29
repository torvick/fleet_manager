require 'rails_helper'

RSpec.describe MaintenanceService, type: :model do
  let(:vehicle) { create(:vehicle, status: :active) }

  it 'requiere completed_at cuando status es completed' do
    ms = build(:maintenance_service, vehicle: vehicle, status: :completed, completed_at: nil)
    expect(ms).not_to be_valid
  end

  it 'no permite fecha futura' do
    ms = build(:maintenance_service, vehicle: vehicle, date: Date.tomorrow)
    expect(ms).not_to be_valid
  end

  it 'actualiza vehicle.status en create' do
    create(:maintenance_service, vehicle: vehicle, status: :pending, date: Time.zone.today, cost_cents: 1000,
                                 priority: :low)
    expect(vehicle.reload.status).to eq('in_maintenance')
  end

  it 'vuelve a active al completar el último servicio abierto' do
    ms = create(:maintenance_service, vehicle: vehicle, status: :pending, date: Time.zone.today, cost_cents: 1000,
                                      priority: :low)
    ms.update!(status: :completed, completed_at: Time.current)
    expect(vehicle.reload.status).to eq('active')
  end
end

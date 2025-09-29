require 'rails_helper'

RSpec.describe 'Reports API', type: :request do
  let(:user)           { User.create!(email: 'tester@example.com', password: 'password123', role: 'admin') }
  let(:vehicle_toyota) { create(:vehicle, brand: 'Toyota', model: 'Corolla', plate: 'ABC123') }
  let(:vehicle_honda)  { create(:vehicle, brand: 'Honda',  model: 'Civic',   plate: 'XYZ987') }
  let(:token)          { JwtEncoder.encode({ sub: user.email, role: user.role }) }
  let(:headers)        { { 'Authorization' => "Bearer #{token}" } }

  before do
    create(:maintenance_service, vehicle: vehicle_toyota, status: :pending,   date: Date.new(2025, 1, 10),
                                 cost_cents: 1000)
    create(:maintenance_service, vehicle: vehicle_toyota, status: :completed, date: Date.new(2025, 1, 20),
                                 cost_cents: 2000, completed_at: Time.current)
    create(:maintenance_service, vehicle: vehicle_honda,  status: :completed, date: Date.new(2025, 1, 25),
                                 cost_cents: 3000, completed_at: Time.current)
    create(:maintenance_service, vehicle: vehicle_honda,  status: :completed, date: Date.new(2024, 12, 31),
                                 cost_cents: 9999, completed_at: Time.current)
  end

  describe 'GET /api/v1/reports/maintenance_summary' do
    it 'returns correct totals' do
      get '/api/v1/reports/maintenance_summary', params: { from: '2025-01-01', to: '2025-12-31' }, headers: headers
      expect(response).to have_http_status(:ok)
      totals = response.parsed_body.dig('data', 'totals')
      expect(totals['orders_count']).to eq(3)
      expect(totals['total_cost_cents']).to eq(6000)
    end

    it 'includes readable breakdown by status' do
      get '/api/v1/reports/maintenance_summary', params: { from: '2025-01-01', to: '2025-12-31' }, headers: headers
      by_status = response.parsed_body.dig('data', 'breakdown_by_status')
      expect(by_status.pluck('key')).to include('pending', 'completed')
    end

    it 'includes breakdown and top by vehicle' do
      get '/api/v1/reports/maintenance_summary', params: { from: '2025-01-01', to: '2025-12-31' }, headers: headers
      body       = response.parsed_body['data']
      by_vehicle = body['breakdown_by_vehicle']
      top        = body['top_vehicles_by_cost']

      ids = by_vehicle.pluck('vehicle_id')
      expect(ids).to include(vehicle_toyota.id, vehicle_honda.id)

      expect(top).to be_an(Array)
      expect(top.first).to have_key('vehicle_id')
      expect(top.first).to have_key('total_cost_cents')
    end

    it 'filters by vehicle_id' do
      get '/api/v1/reports/maintenance_summary',
          params: { vehicle_id: vehicle_toyota.id, from: '2025-01-01', to: '2025-12-31' },
          headers: headers

      totals = response.parsed_body.dig('data', 'totals')
      expect(totals['orders_count']).to eq(2)
      expect(totals['total_cost_cents']).to eq(3000)

      by_vehicle = response.parsed_body.dig('data', 'breakdown_by_vehicle')
      expect(by_vehicle.size).to eq(1)
      expect(by_vehicle.first['vehicle_id']).to eq(vehicle_toyota.id)
    end

    it 'respects the date range' do
      get '/api/v1/reports/maintenance_summary',
          params: { from: '2025-01-15', to: '2025-01-31' },
          headers: headers

      totals = response.parsed_body.dig('data', 'totals')
      expect(totals['orders_count']).to eq(2)
      expect(totals['total_cost_cents']).to eq(5000)
    end

    context 'when CSV export' do
      it 'returns CSV content with correct headers' do
        get '/api/v1/reports/maintenance_summary',
            params: { from: '2025-01-01', to: '2025-12-31', export_format: 'csv' },
            headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('text/csv')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('maintenance_summary_')
        expect(response.headers['Content-Disposition']).to include('.csv')

        csv_content = response.body
        expect(csv_content).to include('TOTALES')
        expect(csv_content).to include('RESUMEN POR ESTADO')
        expect(csv_content).to include('RESUMEN POR VEHÍCULO')
        expect(csv_content).to include('TOP VEHÍCULOS POR COSTO')
      end

      it 'includes vehicle data in CSV' do
        get '/api/v1/reports/maintenance_summary',
            params: { from: '2025-01-01', to: '2025-12-31', export_format: 'csv' },
            headers: headers

        csv_content = response.body
        expect(csv_content).to include('Toyota')
        expect(csv_content).to include('Honda')
        expect(csv_content).to include('ABC123')
        expect(csv_content).to include('XYZ987')
      end
    end

    context 'when Excel export' do
      it 'returns Excel content with correct headers' do
        get '/api/v1/reports/maintenance_summary',
            params: { from: '2025-01-01', to: '2025-12-31', export_format: 'xlsx' },
            headers: headers

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to include('application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
        expect(response.headers['Content-Disposition']).to include('attachment')
        expect(response.headers['Content-Disposition']).to include('maintenance_summary_')
        expect(response.headers['Content-Disposition']).to include('.xlsx')
        expect(response.body).not_to be_empty
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'MaintenanceServices API', type: :request do
  let!(:user)     { User.create!(email: 'tester@example.com', password: 'password123', role: 'admin') }
  let!(:vehicle)  { create(:vehicle) }
  let!(:svc)      { create(:maintenance_service, vehicle: vehicle, status: :pending, date: Time.zone.today) }
  let(:token)     { JwtEncoder.encode({ sub: user.email, role: user.role }) }
  let(:headers)   { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/vehicles/:vehicle_id/maintenance_services' do
    it 'lista servicios con paginación' do
      get "/api/v1/vehicles/#{vehicle.id}/maintenance_services", headers: headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_an(Array)
      expect(response.parsed_body['meta']).to be_present
    end
  end

  describe 'POST /api/v1/vehicles/:vehicle_id/maintenance_services' do
    it 'crea un servicio pendiente' do
      payload = {
        maintenance_service: {
          description: 'Cambio de aceite',
          status: 'pending',
          date: Time.zone.today.to_s,
          cost_cents: 1500,
          priority: 'medium'
        }
      }
      post "/api/v1/vehicles/#{vehicle.id}/maintenance_services", params: payload, headers: headers
      expect(response).to have_http_status(:created)
      expect(response.parsed_body['id']).to be_present
    end
  end

  describe 'PATCH /api/v1/maintenance_services/:id' do
    it 'rechaza completed sin completed_at' do
      patch "/api/v1/maintenance_services/#{svc.id}",
            params: { maintenance_service: { status: 'completed' } },
            headers: headers
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'cuando el servicio existe' do
    it 'elimina el servicio exitosamente' do
      delete "/api/v1/maintenance_services/#{svc.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(MaintenanceService.find_by(id: svc.id)).to be_nil
    end
  end

  describe 'cuando el servicio no existe' do
    it 'retorna 204 No Content (comportamiento idempotente)' do
      delete '/api/v1/maintenance_services/99999', headers: headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end

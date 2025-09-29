require 'rails_helper'

RSpec.describe 'MaintenanceServices API', type: :request do
  let(:ctx) do
    {
      admin: User.create!(email: 'tester@example.com', password: 'password123', role: :admin),
      viewer: create(:user, role: :viewer),
      vehicle: create(:vehicle)
    }
  end

  let!(:svc) { create(:maintenance_service, vehicle: ctx[:vehicle], status: :pending, date: Time.zone.today) }

  def auth_headers(user)
    token = JwtEncoder.encode({ sub: user.email, role: user.role })
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /api/v1/vehicles/:vehicle_id/maintenance_services' do
    before do
      create(:maintenance_service, vehicle: ctx[:vehicle], description: 'Deleted').tap(&:discard)
    end

    it 'lists only active services by default' do
      get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services", headers: auth_headers(ctx[:admin])
      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.size).to eq(1)
      expect(data.first['description']).not_to eq('Deleted')
    end

    context 'when the user is admin' do
      it 'can see discarded services with only_discarded=true' do
        get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services",
            params: { only_discarded: 'true' }, headers: auth_headers(ctx[:admin])
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['description']).to eq('Deleted')
      end

      it 'can see all services with include_discarded=true' do
        get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services",
            params: { include_discarded: 'true' }, headers: auth_headers(ctx[:admin])
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(2)
        descriptions = data.pluck('description')
        expect(descriptions).to include('Deleted')
      end
    end

    context 'when the user is not admin' do
      it 'cannot see discarded services even with only_discarded=true' do
        get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services",
            params: { only_discarded: 'true' }, headers: auth_headers(ctx[:viewer])
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['description']).not_to eq('Deleted')
      end

      it 'cannot include discarded services even with include_discarded=true' do
        get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services",
            params: { include_discarded: 'true' }, headers: auth_headers(ctx[:viewer])
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['description']).not_to eq('Deleted')
      end
    end

    it 'lists services with pagination' do
      get "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services", headers: auth_headers(ctx[:admin])
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_an(Array)
      expect(response.parsed_body['meta']).to be_present
    end
  end

  describe 'POST /api/v1/vehicles/:vehicle_id/maintenance_services' do
    it 'creates a pending service' do
      payload = {
        maintenance_service: {
          description: 'Oil change',
          status: 'pending',
          date: Time.zone.today.to_s,
          cost_cents: 1500,
          priority: 'medium'
        }
      }
      post "/api/v1/vehicles/#{ctx[:vehicle].id}/maintenance_services", params: payload,
                                                                        headers: auth_headers(ctx[:admin])
      expect(response).to have_http_status(:created)
      expect(response.parsed_body['id']).to be_present
    end
  end

  describe 'PATCH /api/v1/maintenance_services/:id' do
    it 'rejects completed status without completed_at' do
      patch "/api/v1/maintenance_services/#{svc.id}",
            params: { maintenance_service: { status: 'completed' } },
            headers: auth_headers(ctx[:admin])
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'when the service exists' do
    it 'soft deletes the service successfully' do
      delete "/api/v1/maintenance_services/#{svc.id}", headers: auth_headers(ctx[:admin])

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(MaintenanceService.kept.find_by(id: svc.id)).to be_nil
      expect(MaintenanceService.with_discarded.find_by(id: svc.id)).to be_present
      expect(MaintenanceService.with_discarded.find_by(id: svc.id).discarded?).to be true
    end
  end

  describe 'when the service does not exist' do
    it 'returns 204 No Content (idempotent)' do
      delete '/api/v1/maintenance_services/99999', headers: auth_headers(ctx[:admin])

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end

  describe 'POST /api/v1/maintenance_services/:id/restore' do
    context 'when the service is discarded (soft delete)' do
      before { svc.discard }

      it 'restores the service successfully' do
        post "/api/v1/maintenance_services/#{svc.id}/restore", headers: auth_headers(ctx[:admin])

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['id']).to eq(svc.id)
        expect(MaintenanceService.find_by(id: svc.id)).to be_present
        expect(MaintenanceService.find_by(id: svc.id).discarded?).to be false
      end
    end

    context 'when the service does not exist' do
      it 'returns 204 No Content' do
        post '/api/v1/maintenance_services/99999/restore', headers: auth_headers(ctx[:admin])

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when the user has no permission' do
      before { svc.discard }

      it 'returns 403 Forbidden' do
        viewer = ctx[:viewer]
        token  = JwtEncoder.encode({ sub: viewer.email, role: viewer.role })
        post "/api/v1/maintenance_services/#{svc.id}/restore",
             headers: { 'Authorization' => "Bearer #{token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'Authorization API', type: :request do
  def auth_headers(user)
    token = JwtEncoder.encode({ sub: user.email, role: user.role })
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'Vehicle permissions' do
    let(:admin) { create(:user, role: :admin) }
    let(:manager) { create(:user, role: :manager) }
    let(:viewer) { create(:user, role: :viewer) }
    let(:vehicle) { create(:vehicle) }

    context 'when accessing vehicles index' do
      it 'allows all roles to view vehicles' do
        [admin, manager, viewer].each do |user|
          get '/api/v1/vehicles', headers: auth_headers(user)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when creating vehicles' do
      it 'allows admin and manager to create vehicles' do
        [admin, manager].each_with_index do |user, index|
          vehicle_params = {
            vehicle: {
              vin: "TEST12#{index}#{rand(1000)}",
              plate: "ABC12#{index}",
              brand: 'Test',
              model: 'Model',
              year: 2023
            }
          }
          post '/api/v1/vehicles', params: vehicle_params, headers: auth_headers(user)
          expect(response).to have_http_status(:created)
        end
      end

      it 'denies viewer from creating vehicles' do
        vehicle_params = {
          vehicle: {
            vin: "VIEWER#{rand(10_000)}",
            plate: 'VWR123',
            brand: 'Test',
            model: 'Model',
            year: 2023
          }
        }
        post '/api/v1/vehicles', params: vehicle_params, headers: auth_headers(viewer)
        expect(response).to have_http_status(:forbidden)
        expect(response.parsed_body['error']['code']).to eq('forbidden')
      end
    end

    context 'when deleting vehicles' do
      it 'allows only admin to delete vehicles' do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers(admin)
        expect(response).to have_http_status(:no_content)
      end

      it 'denies manager from deleting vehicles' do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers(manager)
        expect(response).to have_http_status(:forbidden)
      end

      it 'denies viewer from deleting vehicles' do
        delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers(viewer)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe 'MaintenanceService permissions' do
    let(:admin) { create(:user, role: :admin) }
    let(:manager) { create(:user, role: :manager) }
    let(:viewer) { create(:user, role: :viewer) }
    let(:vehicle) { create(:vehicle) }
    let(:maintenance_service) { create(:maintenance_service, vehicle: vehicle) }

    context 'when accessing maintenance services index' do
      it 'allows all roles to view maintenance services' do
        [admin, manager, viewer].each do |user|
          get "/api/v1/vehicles/#{vehicle.id}/maintenance_services", headers: auth_headers(user)
          expect(response).to have_http_status(:ok)
        end
      end
    end

    context 'when creating maintenance services' do
      it 'allows admin and manager to create services' do
        [admin, manager].each do |user|
          service_params = {
            maintenance_service: {
              description: 'Test service',
              date: Date.current,
              cost_cents: 10_000,
              priority: 'medium'
            }
          }
          post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
               params: service_params, headers: auth_headers(user)
          expect(response).to have_http_status(:created)
        end
      end

      it 'denies viewer from creating services' do
        service_params = {
          maintenance_service: {
            description: 'Test service',
            date: Date.current,
            cost_cents: 10_000,
            priority: 'medium'
          }
        }
        post "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
             params: service_params, headers: auth_headers(viewer)
        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when deleting maintenance services' do
      it 'allows only admin to delete services' do
        delete "/api/v1/maintenance_services/#{maintenance_service.id}", headers: auth_headers(admin)
        expect(response).to have_http_status(:no_content)
      end

      it 'denies manager from deleting services' do
        delete "/api/v1/maintenance_services/#{maintenance_service.id}", headers: auth_headers(manager)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

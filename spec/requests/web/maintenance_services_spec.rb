require 'rails_helper'

RSpec.describe 'Web Maintenance Services', type: :request do
  let!(:vehicle)          { create(:vehicle) }
  let!(:active_service)   { create(:maintenance_service, vehicle: vehicle, description: 'Active', status: :pending) }
  let!(:discarded_service) { create(:maintenance_service, :completed, vehicle: vehicle, description: 'Discarded') }

  before do
    discarded_service.discard
  end

  describe 'GET /vehicles/:vehicle_id/maintenance_services/new' do
    it 'renders the new service form' do
      get "/vehicles/#{vehicle.id}/maintenance_services/new"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /vehicles/:vehicle_id/maintenance_services' do
    let(:valid_params) do
      {
        maintenance_service: {
          description: 'Oil change',
          status: 'pending',
          date: Date.current,
          cost_cents: 5000,
          priority: 'medium'
        }
      }
    end

    it 'creates a service successfully' do
      expect do
        post "/vehicles/#{vehicle.id}/maintenance_services", params: valid_params
      end.to change(MaintenanceService, :count).by(1)

      expect(response).to redirect_to(vehicle)
    end

    it 'shows errors for invalid data' do
      invalid_params = valid_params.dup
      invalid_params[:maintenance_service][:description] = ''

      post "/vehicles/#{vehicle.id}/maintenance_services", params: invalid_params
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'GET /vehicles/:vehicle_id/maintenance_services/:id/edit' do
    it 'renders the edit form' do
      get "/vehicles/#{vehicle.id}/maintenance_services/#{active_service.id}/edit"
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'PATCH /vehicles/:vehicle_id/maintenance_services/:id' do
    let(:update_params) do
      {
        maintenance_service: {
          description: 'Updated description'
        }
      }
    end

    it 'updates the service successfully' do
      patch "/vehicles/#{vehicle.id}/maintenance_services/#{active_service.id}", params: update_params

      active_service.reload
      expect(active_service.description).to eq('Updated description')
      expect(response).to redirect_to(vehicle)
      follow_redirect!
    end

    it 'shows errors for invalid data' do
      invalid_params = { maintenance_service: { date: Date.tomorrow } }

      patch "/vehicles/#{vehicle.id}/maintenance_services/#{active_service.id}", params: invalid_params
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'DELETE /vehicles/:vehicle_id/maintenance_services/:id' do
    it 'soft deletes the service' do
      expect do
        delete "/vehicles/#{vehicle.id}/maintenance_services/#{active_service.id}"
      end.not_to change(MaintenanceService, :count)

      active_service.reload
      expect(active_service.discarded?).to be true
      expect(response).to redirect_to(vehicle)
      follow_redirect!
    end
  end

  describe 'POST /vehicles/:vehicle_id/maintenance_services/:id/restore' do
    it 'restores a discarded service successfully' do
      post "/vehicles/#{vehicle.id}/maintenance_services/#{discarded_service.id}/restore"

      discarded_service.reload
      expect(discarded_service.discarded?).to be false
      expect(response).to redirect_to(vehicle)
      follow_redirect!
    end
  end

  describe 'business validations' do
    it 'does not allow future dates' do
      invalid_params = {
        maintenance_service: {
          description: 'Test',
          date: Date.tomorrow,
          status: 'pending',
          priority: 'medium',
          cost_cents: 1000
        }
      }

      post "/vehicles/#{vehicle.id}/maintenance_services", params: invalid_params
      expect(response).to have_http_status(:unprocessable_content)
    end

    it 'requires completed_at for completed status' do
      invalid_params = {
        maintenance_service: {
          description: 'Test',
          date: Date.current,
          status: 'completed',
          priority: 'medium',
          cost_cents: 1000
        }
      }

      post "/vehicles/#{vehicle.id}/maintenance_services", params: invalid_params
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end

require 'rails_helper'

RSpec.describe 'Web Vehicles', type: :request do
  let!(:active_vehicle)    { create(:vehicle, brand: 'Toyota', model: 'Corolla', year: 2020) }
  let!(:discarded_vehicle) { create(:vehicle, brand: 'Ford',   model: 'Focus',   year: 2021) }

  before { discarded_vehicle.discard }

  describe 'GET /vehicles' do
    it 'shows only active vehicles by default' do
      get '/vehicles'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Toyota')
      expect(response.body).not_to include('Ford')
    end

    it 'includes search filters' do
      get '/vehicles', params: { q: 'toyota' }
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Toyota')
    end

    it 'includes a button to view discarded vehicles' do
      get '/vehicles'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ver eliminados')
    end
  end

  describe 'GET /vehicles/discarded' do
    it 'shows a discarded indicator in the title' do
      get '/vehicles/discarded'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('(Eliminados)')
    end

    it 'includes a button to view active vehicles' do
      get '/vehicles/discarded'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Ver activos')
    end

    it 'shows restore buttons for discarded vehicles' do
      get '/vehicles/discarded'
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Restaurar')
    end
  end

  describe 'GET /vehicles/:id' do
    it 'shows details of an active vehicle' do
      get "/vehicles/#{active_vehicle.id}"
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Toyota')
      expect(response.body).to include('Corolla')
    end

    context 'with active and discarded services' do
      before do
        create(:maintenance_service, vehicle: active_vehicle, description: 'Active')
        create(:maintenance_service, vehicle: active_vehicle, description: 'Discarded').tap(&:discard)
      end

      it 'shows only active services by default' do
        get "/vehicles/#{active_vehicle.id}"
        expect(response).to have_http_status(:ok)
      end

      it 'shows discarded services when show_discarded=true' do
        get "/vehicles/#{active_vehicle.id}", params: { show_discarded: 'true' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Eliminado')
        expect(response.body).not_to include('Activo')
      end

      it 'includes a button to view discarded services' do
        get "/vehicles/#{active_vehicle.id}"
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Ver eliminados')
      end

      it 'includes a button to view active services when viewing discarded ones' do
        get "/vehicles/#{active_vehicle.id}", params: { show_discarded: 'true' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Ver activos')
      end

      it 'shows restore buttons for discarded services' do
        get "/vehicles/#{active_vehicle.id}", params: { show_discarded: 'true' }
        expect(response).to have_http_status(:ok)
        expect(response.body).to include('Restaurar')
      end
    end
  end
end

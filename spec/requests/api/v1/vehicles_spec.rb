require 'rails_helper'

RSpec.describe 'Vehicles API', type: :request do
  let!(:user) { User.create!(email: 'tester@example.com', password: 'password123', role: :admin) }
  let(:token) { JwtEncoder.encode({ sub: user.email, role: user.role }) }

  def auth_headers
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /api/v1/vehicles' do
    # Evitamos let! para datos no referenciados directamente
    before do
      create(:vehicle, brand: 'Toyota', model: 'Corolla', year: 2020) # activo
      create(:vehicle, brand: 'Ford',   model: 'Focus',   year: 2021).tap(&:discard) # descartado
    end

    it 'lists only active vehicles by default' do
      get '/api/v1/vehicles', headers: auth_headers
      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      expect(data.size).to eq(1)
      expect(data.first['brand']).to eq('Toyota')
    end

    it 'filters by search query' do
      get '/api/v1/vehicles', params: { q: 'toy' }, headers: auth_headers
      brands = response.parsed_body['data'].pluck('brand')
      expect(brands).to include('Toyota')
    end

    context 'when the user is admin' do
      it 'can view discarded vehicles with only_discarded=true' do
        get '/api/v1/vehicles', params: { only_discarded: 'true' }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['brand']).to eq('Ford')
      end

      it 'can view all vehicles with include_discarded=true' do
        get '/api/v1/vehicles', params: { include_discarded: 'true' }, headers: auth_headers
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(2)
        brands = data.pluck('brand')
        expect(brands).to include('Toyota', 'Ford')
      end
    end

    context 'when the user is not admin' do
      # Reducimos memoized helpers: creamos usuario y headers dentro de cada ejemplo
      it 'cannot view discarded vehicles even with only_discarded=true' do
        viewer = User.create!(email: "viewer_vehicles_#{rand(1000)}@example.com",
                              password: 'password123', role: :viewer)
        viewer_token   = JwtEncoder.encode({ sub: viewer.email, role: viewer.role })
        viewer_headers = { 'Authorization' => "Bearer #{viewer_token}" }

        get '/api/v1/vehicles', params: { only_discarded: 'true' }, headers: viewer_headers
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['brand']).to eq('Toyota')
      end

      it 'cannot include discarded vehicles even with include_discarded=true' do
        viewer = User.create!(email: "viewer_vehicles_#{rand(1000)}@example.com",
                              password: 'password123', role: :viewer)
        viewer_token   = JwtEncoder.encode({ sub: viewer.email, role: viewer.role })
        viewer_headers = { 'Authorization' => "Bearer #{viewer_token}" }

        get '/api/v1/vehicles', params: { include_discarded: 'true' }, headers: viewer_headers
        expect(response).to have_http_status(:ok)
        data = response.parsed_body['data']
        expect(data.size).to eq(1)
        expect(data.first['brand']).to eq('Toyota')
      end
    end
  end

  describe 'POST /api/v1/vehicles' do
    it 'creates a vehicle' do
      payload = {
        vehicle: {
          vin: '1HGCM82633A004352',
          plate: 'XYZ987',
          brand: 'Honda',
          model: 'Civic',
          year: 2020,
          status: 'active'
        }
      }
      post '/api/v1/vehicles', params: payload, headers: auth_headers
      expect(response).to have_http_status(:created)
      expect(response.parsed_body['id']).to be_present
    end
  end

  describe 'when the vehicle exists' do
    let!(:vehicle) { create(:vehicle) }

    it 'soft deletes the vehicle successfully' do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(Vehicle.kept.find_by(id: vehicle.id)).to be_nil
      expect(Vehicle.with_discarded.find_by(id: vehicle.id)).to be_present
      expect(Vehicle.with_discarded.find_by(id: vehicle.id).discarded?).to be true
    end
  end

  describe 'when the vehicle does not exist' do
    it 'returns 204 No Content (idempotent behavior)' do
      delete '/api/v1/vehicles/99999', headers: auth_headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end

  describe 'POST /api/v1/vehicles/:id/restore' do
    context 'when the vehicle is discarded (soft delete)' do
      let!(:vehicle) { create(:vehicle) }

      before { vehicle.discard }

      it 'restores the vehicle successfully' do
        post "/api/v1/vehicles/#{vehicle.id}/restore", headers: auth_headers

        expect(response).to have_http_status(:ok)
        expect(response.parsed_body['id']).to eq(vehicle.id)
        expect(Vehicle.find_by(id: vehicle.id)).to be_present
        expect(Vehicle.find_by(id: vehicle.id).discarded?).to be false
      end
    end

    context 'when the vehicle does not exist' do
      it 'returns 204 No Content' do
        post '/api/v1/vehicles/99999/restore', headers: auth_headers

        expect(response).to have_http_status(:no_content)
        expect(response.body).to be_empty
      end
    end

    context 'when the user does not have permissions' do
      let!(:vehicle) { create(:vehicle) }

      before { vehicle.discard }

      it 'returns 403 Forbidden' do
        viewer = User.create!(email: "viewer_restore_#{rand(1000)}@example.com",
                              password: 'password123', role: :viewer)
        viewer_token = JwtEncoder.encode({ sub: viewer.email, role: viewer.role })

        post "/api/v1/vehicles/#{vehicle.id}/restore",
             headers: { 'Authorization' => "Bearer #{viewer_token}" }

        expect(response).to have_http_status(:forbidden)
      end
    end
  end
end

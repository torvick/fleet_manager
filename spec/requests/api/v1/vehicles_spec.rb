require 'rails_helper'

RSpec.describe 'Vehicles API', type: :request do
  let!(:user) { User.create!(email: 'tester@example.com', password: 'password123', role: 'admin') }
  let(:token) { JwtEncoder.encode({ sub: user.email, role: user.role }) }

  def auth_headers
    { 'Authorization' => "Bearer #{token}" }
  end

  describe 'GET /api/v1/vehicles' do
    before do
      create(:vehicle, brand: 'Toyota', model: 'Corolla', year: 2020)
      create(:vehicle, brand: 'Ford',   model: 'Focus',   year: 2021)
    end

    it 'lista vehículos' do
      get '/api/v1/vehicles', headers: auth_headers
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['data']).to be_present
      expect(response.parsed_body['meta']).to be_present
    end

    it 'filtra por búsqueda' do
      get '/api/v1/vehicles', params: { q: 'toy' }, headers: auth_headers
      brands = response.parsed_body['data'].pluck('brand')
      expect(brands).to include('Toyota')
    end
  end

  describe 'POST /api/v1/vehicles' do
    it 'crea un vehículo' do
      payload = {
        vehicle: { vin: '1HGCM82633A004352', plate: 'XYZ987', brand: 'Honda', model: 'Civic', year: 2020,
                   status: 'active' }
      }
      post '/api/v1/vehicles', params: payload, headers: auth_headers
      expect(response).to have_http_status(:created)
      expect(response.parsed_body['id']).to be_present
    end
  end

  describe 'cuando el vehículo existe' do
    let!(:vehicle) { create(:vehicle) }

    it 'elimina el vehículo exitosamente' do
      delete "/api/v1/vehicles/#{vehicle.id}", headers: auth_headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
      expect(Vehicle.find_by(id: vehicle.id)).to be_nil
    end
  end

  describe 'cuando el vehículo no existe' do
    it 'retorna 204 No Content (comportamiento idempotente)' do
      delete '/api/v1/vehicles/99999', headers: auth_headers

      expect(response).to have_http_status(:no_content)
      expect(response.body).to be_empty
    end
  end
end

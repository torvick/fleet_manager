require 'rails_helper'

RSpec.describe 'API Pagy Overflow Handling', type: :request do
  let!(:user) { User.create!(email: 'admin@example.com', password: 'password123', role: :admin) }
  let(:token) { JwtEncoder.encode({ sub: user.email, role: user.role }) }
  let(:headers) { { 'Authorization' => "Bearer #{token}" } }

  describe 'GET /api/v1/vehicles with non-existent pages' do
    let!(:vehicles) { create_list(:vehicle, 5) }

    it 'redirects to the last page when a non-existent page is requested' do
      get '/api/v1/vehicles', params: { page: 999 }, headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']
      expect(meta['page']).to eq(1)
      expect(meta['pages']).to eq(1)
      expect(meta['last']).to eq(1)
    end

    it 'redirects to the last page with filters applied' do
      vehicles.first.discard

      get '/api/v1/vehicles', params: { page: 10, only_discarded: 'true' }, headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']
      expect(meta['page']).to eq(1)
      expect(meta['pages']).to eq(1)
      data = response.parsed_body['data']
      expect(data.size).to eq(1)
    end

    it 'handles overflow with include_discarded' do
      vehicles.take(2).each(&:discard)

      get '/api/v1/vehicles', params: { page: 5, include_discarded: 'true' }, headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']
      expect(meta['page']).to eq(1)
      data = response.parsed_body['data']
      expect(data.size).to eq(5)
    end
  end

  describe 'GET /api/v1/vehicles/:vehicle_id/maintenance_services with non-existent pages' do
    let!(:vehicle) { create(:vehicle) }
    let!(:services) { create_list(:maintenance_service, 3, vehicle: vehicle) }

    it 'redirects to the last page when a non-existent page is requested' do
      get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
          params: { page: 999 }, headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']
      expect(meta['page']).to eq(1)
      expect(meta['pages']).to eq(1)
    end

    it 'handles overflow with discarded services' do
      services.first.discard

      get "/api/v1/vehicles/#{vehicle.id}/maintenance_services",
          params: { page: 10, only_discarded: 'true' }, headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']
      expect(meta['page']).to eq(1)
      data = response.parsed_body['data']
      expect(data.size).to eq(1)
    end
  end

  describe 'Pagy configuration' do
    before do
      3.times { create_list(:vehicle, 10) }
      Vehicle.limit(25)
    end

    it 'uses the default limit of 20 items' do
      get '/api/v1/vehicles', headers: headers

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      meta = response.parsed_body['meta']

      expect(data.size).to eq(20)
      expect(meta['limit']).to eq(20)
      expect(meta['pages']).to eq(2)
    end

    it 'respects the custom items parameter' do
      get '/api/v1/vehicles', params: { items: 10 }, headers: headers

      expect(response).to have_http_status(:ok)
      data = response.parsed_body['data']
      meta = response.parsed_body['meta']

      expect(data.size).to eq(10)
      expect(meta['limit']).to eq(10)
      expect(meta['pages']).to eq(3)
    end

    it 'includes full metadata' do
      get '/api/v1/vehicles', headers: headers

      expect(response).to have_http_status(:ok)
      meta = response.parsed_body['meta']

      required_keys = %w[count page limit pages last in from to]
      required_keys.each do |key|
        expect(meta).to have_key(key)
      end
    end
  end
end

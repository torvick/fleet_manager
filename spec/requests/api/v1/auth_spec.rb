require 'rails_helper'

RSpec.describe 'Auth', type: :request do
  before { User.create!(email: 'tester@example.com', password: 'password123', role: 'admin') }

  it 'returns a JWT for valid credentials' do
    post '/api/v1/auth/login', params: { email: 'tester@example.com', password: 'password123' }
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body['token']).to be_present
  end
end

require 'rails_helper'

RSpec.describe 'Health', type: :request do
  it 'returns status ok' do
    get '/health'
    expect(response).to have_http_status(:ok)
  end

  it 'returns ok: true in payload' do
    get '/health'
    expect(response.parsed_body).to include('ok' => true)
  end
end

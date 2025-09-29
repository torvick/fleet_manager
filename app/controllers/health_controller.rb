class HealthController < ApplicationController
  def show
    render json: { ok: true, time: Time.zone.now }, status: :ok
  end
end

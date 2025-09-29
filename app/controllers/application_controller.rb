class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session

  rescue_from ::JWT::ExpiredSignature do
    render json: { error: { code: 'token_expired', message: 'Unauthorized' } }, status: :unauthorized
  end

  rescue_from ::JWT::DecodeError do
    render json: { error: { code: 'invalid_token', message: 'Unauthorized' } }, status: :unauthorized
  end

  rescue_from ActiveRecord::RecordNotFound do |e|
    render_error(404, 'not_found', e.message)
  end

  rescue_from ActiveRecord::RecordInvalid do |e|
    render_error(422, 'record_invalid', e.record.errors.full_messages)
  end

  rescue_from ActionController::ParameterMissing do |e|
    render_error(400, 'bad_request', e.message)
  end

  private

  def render_error(status, code, details = nil)
    render json: {
      error: {
        code: code,
        message: Rack::Utils::HTTP_STATUS_CODES[status],
        details: details
      }
    }, status: status
  end
end

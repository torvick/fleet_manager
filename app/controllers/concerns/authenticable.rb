module Authenticable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  def authenticate!
    header = request.headers['Authorization'].to_s
    token = header.split.last
    return unauthorized!('missing_token') if token.blank?

    payload = JwtEncoder.decode(token)
    @current_user = User.find_by(email: payload[:sub])
    unauthorized!('user_not_found') unless @current_user
  rescue JWT::ExpiredSignature
    unauthorized!('token_expired')
  rescue JWT::DecodeError
    unauthorized!('invalid_token')
  end

  private

  def unauthorized!(code)
    render json: { error: { code: code, message: 'Unauthorized' } }, status: :unauthorized
  end
end

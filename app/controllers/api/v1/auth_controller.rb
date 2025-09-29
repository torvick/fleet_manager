module Api
  module V1
    class AuthController < ApplicationController
      skip_forgery_protection
      before_action -> { request.format = :json }

      def login
        user = find_user
        return unauth unless user&.authenticate(login_params[:password])

        render json: token_response_for(user), status: :ok
      end

      private

      def login_params
        {
          email: params.require(:email).to_s.strip.downcase,
          password: params.require(:password)
        }
      end

      def find_user
        User.find_by(email: login_params[:email])
      end

      def token_response_for(user)
        token = JwtEncoder.encode({ sub: user.email, role: user.role })
        {
          token: token,
          token_type: 'Bearer',
          expires_in: 24.hours.to_i,
          user: { email: user.email, role: user.role }
        }
      end

      def unauth
        render json: { error: { code: 'invalid_credentials', message: 'Unauthorized' } }, status: :unauthorized
      end
    end
  end
end

module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable
      include Pundit::Authorization

      skip_forgery_protection
      before_action :force_json
      before_action :authenticate!

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden

      private

      def force_json
        request.format = :json
      end

      def render_validation_error(record)
        render json: {
          error: {
            code: 'validation_error',
            message: 'Unprocessable Entity',
            details: record.errors
          }
        }, status: :unprocessable_content
      end

      def render_forbidden
        render json: {
          error: {
            code: 'forbidden',
            message: 'Forbidden',
            details: 'You are not authorized to perform this action'
          }
        }, status: :forbidden
      end
    end
  end
end

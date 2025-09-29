module Api
  module V1
    class BaseController < ApplicationController
      include Authenticable

      skip_forgery_protection
      before_action :force_json
      before_action :authenticate!

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
    end
  end
end

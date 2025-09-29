# frozen_string_literal: true

module Api
  module V1
    class ReportsController < BaseController
      # GET /api/v1/reports/maintenance_summary
      def maintenance_summary
        results = Reports::MaintenanceSummary.new(
          from: summary_params[:from],
          to: summary_params[:to],
          vehicle_id: summary_params[:vehicle_id]
        ).call

        render json: { data: results, meta: summary_params }, status: :ok
      end

      private

      def summary_params
        {
          from: params[:from],
          to: params[:to],
          vehicle_id: params[:vehicle_id].presence
        }
      end
    end
  end
end

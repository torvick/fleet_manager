module Api
  module V1
    class ReportsController < BaseController
      skip_before_action :force_json, only: [:maintenance_summary]
      before_action :build_summary_results, only: :maintenance_summary

      # GET /api/v1/reports/maintenance_summary
      def maintenance_summary
        case export_format
        when :csv  then send_csv(@results)
        when :xlsx then send_xlsx(@results)
        else            render_json(@results)
        end
      end

      private

      def summary_params
        {
          from: params[:from],
          to: params[:to],
          vehicle_id: params[:vehicle_id].presence
        }
      end

      def build_summary_results
        @results = Reports::MaintenanceSummary.new(
          from: summary_params[:from],
          to: summary_params[:to],
          vehicle_id: summary_params[:vehicle_id]
        ).call
      end

      def export_format
        @export_format ||= params[:export_format]&.to_sym
      end

      def export_filename
        "maintenance_summary_#{Time.current.strftime('%Y%m%d_%H%M%S')}"
      end

      def render_json(results)
        render json: { data: results, meta: summary_params }, status: :ok
      end

      def send_csv(results)
        csv_data = Reports::Exporters::CsvExporter.new(results).call
        send_data csv_data,
                  filename: "#{export_filename}.csv",
                  type: 'text/csv',
                  disposition: 'attachment'
      end

      def send_xlsx(results)
        excel_data = Reports::Exporters::ExcelExporter.new(results).call
        send_data excel_data,
                  filename: "#{export_filename}.xlsx",
                  type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
                  disposition: 'attachment'
      end
    end
  end
end

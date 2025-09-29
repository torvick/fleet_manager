module Web
  class ReportsController < ApplicationController
    before_action :set_filters, :load_results, :load_vehicles, only: :maintenance_summary

    def maintenance_summary
      respond_to do |format|
        format.html
        format.csv  { send_csv(@results) }
        format.xlsx { send_xlsx(@results) }
      end
    end

    private

    def set_filters
      @from       = params[:from].presence || 30.days.ago.to_date.to_s
      @to         = params[:to].presence   || Date.current.to_s
      @vehicle_id = params[:vehicle_id].presence
    end

    def load_results
      @results = Reports::MaintenanceSummary.new(
        from: @from,
        to: @to,
        vehicle_id: @vehicle_id
      ).call
    end

    def load_vehicles
      @vehicles = Vehicle.kept.order(:brand, :model)
    end

    def export_filename
      "maintenance_summary_#{Time.current.strftime('%Y%m%d_%H%M%S')}"
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

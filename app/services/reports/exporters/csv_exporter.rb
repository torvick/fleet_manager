require 'csv'

module Reports
  module Exporters
    class CsvExporter
      VEHICLE_TABLE_HEADER = ['ID Vehículo', 'Marca', 'Modelo', 'Placa', 'Cantidad de servicios', 'Costo total'].freeze
      STATUS_TABLE_HEADER  = ['Estado', 'Cantidad de servicios', 'Costo total', '', ''].freeze
      TOP_TITLE            = 'TOP VEHÍCULOS POR COSTO'.freeze
      VEHICLE_TITLE        = 'RESUMEN POR VEHÍCULO'.freeze
      STATUS_TITLE         = 'RESUMEN POR ESTADO'.freeze

      def initialize(data)
        @data = data
      end

      def call
        rows = []
        rows << headers
        rows.concat(totals_section)
        rows.concat(status_section)
        rows.concat(vehicle_section(VEHICLE_TITLE, @data[:breakdown_by_vehicle]))
        rows.concat(vehicle_section(TOP_TITLE, @data[:top_vehicles_by_cost]))

        CSV.generate(headers: true) { |csv| rows.each { |r| csv << r } }
      end

      private

      # ---------- Sections ----------

      def totals_section
        [
          section_title('TOTALES', 5),
          row_pair('Órdenes totales', @data.dig(:totals, :orders_count)),
          row_pair('Costo total', money(@data.dig(:totals, :total_cost_cents))),
          blank_row
        ]
      end

      def status_section
        section_with_table(
          title: STATUS_TITLE,
          header: STATUS_TABLE_HEADER,
          rows: status_rows(Array(@data[:breakdown_by_status]))
        )
      end

      def vehicle_section(title, collection)
        section_with_table(
          title: title,
          header: VEHICLE_TABLE_HEADER,
          rows: vehicle_rows(Array(collection))
        )
      end

      def section_with_table(title:, header:, rows:)
        out = []
        out << section_title(title, 5)
        out << header
        out.concat(rows)
        out << blank_row
        out
      end

      def status_rows(collection)
        collection.map do |row|
          [row[:key], row[:services_count], money(row[:total_cost_cents]), '', '']
        end
      end

      def vehicle_rows(collection)
        collection.map do |row|
          [row[:vehicle_id], row[:brand], row[:model], row[:plate], row[:services_count], money(row[:total_cost_cents])]
        end
      end

      def headers
        ['Sección', 'Valor 1', 'Valor 2', 'Valor 3', 'Valor 4', 'Valor 5']
      end

      def section_title(text, blanks_after = 0)
        [text] + Array.new(blanks_after, '')
      end

      def row_pair(label, value)
        [label, value, '', '', '']
      end

      def blank_row
        []
      end

      def money(cents)
        return '0.00' if cents.nil?

        format('%.2f', cents.to_i / 100.0)
      end
    end
  end
end

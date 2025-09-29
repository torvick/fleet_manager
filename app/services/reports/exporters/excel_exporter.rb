module Reports
  module Exporters
    class ExcelExporter
      SHEET_NAME        = 'Reporte de Mantenimiento'.freeze
      TITLE_TEXT        = 'REPORTE DE MANTENIMIENTO'.freeze
      TOTALS_TITLE      = 'TOTALES'.freeze
      STATUS_TITLE      = 'RESUMEN POR ESTADO'.freeze
      VEHICLE_TITLE     = 'RESUMEN POR VEHÍCULO'.freeze
      TOP_VEHICLE_TITLE = 'TOP VEHÍCULOS POR COSTO'.freeze

      STATUS_HEADER  = ['Estado', 'Cantidad de servicios', 'Costo total'].freeze
      VEHICLE_HEADER = ['ID Vehículo', 'Marca', 'Modelo', 'Placa', 'Cantidad de servicios', 'Costo total'].freeze

      def initialize(data)
        @data = data
      end

      def call = build_package.to_stream.read

      private

      def build_package
        package = new_package
        styles  = build_styles(package.workbook)
        populate_sheet(package.workbook, styles)
        package
      end

      def new_package = Axlsx::Package.new

      def populate_sheet(workbook, styles)
        workbook.add_worksheet(name: SHEET_NAME) { |sheet| add_sections(sheet, styles) }
      end

      def add_sections(sheet, styles)
        add_title(sheet, styles)
        add_totals_section(sheet, styles)
        add_status_section(sheet, styles)
        add_vehicle_section(sheet, styles, VEHICLE_TITLE, Array(@data[:breakdown_by_vehicle]))
        add_vehicle_section(sheet, styles, TOP_VEHICLE_TITLE, Array(@data[:top_vehicles_by_cost]))
        sheet.column_widths 20, 20, 20, 20, 25, 20
      end

      def build_styles(workbook)
        {
          header: workbook.styles.add_style(bg_color: '4472C4', fg_color: 'FFFFFF', b: true,
                                            alignment: { horizontal: :center }),
          section: workbook.styles.add_style(bg_color: 'D9E1F2', b: true),
          money: workbook.styles.add_style(format_code: '$#,##0.00')
        }
      end

      def add_title(sheet, styles)
        sheet.add_row [TITLE_TEXT], style: styles[:header]
        sheet.add_row []
      end

      def add_totals_section(sheet, styles)
        totals = @data[:totals] || {}
        sheet.add_row [TOTALS_TITLE], style: styles[:section]
        sheet.add_row ['Órdenes totales', totals[:orders_count]]
        sheet.add_row ['Costo total', cents_to_units(totals[:total_cost_cents])], style: [nil, styles[:money]]
        sheet.add_row []
      end

      def add_status_section(sheet, styles)
        sheet.add_row [STATUS_TITLE], style: styles[:section]
        sheet.add_row STATUS_HEADER, style: styles[:header]
        Array(@data[:breakdown_by_status]).each do |row|
          sheet.add_row [row[:key], row[:services_count], cents_to_units(row[:total_cost_cents])],
                        style: [nil, nil, styles[:money]]
        end
        sheet.add_row []
      end

      def add_vehicle_section(sheet, styles, title, collection)
        sheet.add_row [title], style: styles[:section]
        sheet.add_row VEHICLE_HEADER, style: styles[:header]
        collection.each { |row| add_vehicle_row(sheet, styles, row) }
        sheet.add_row []
      end

      def add_vehicle_row(sheet, styles, row)
        sheet.add_row [
          row[:vehicle_id],
          row[:brand],
          row[:model],
          row[:plate],
          row[:services_count],
          cents_to_units(row[:total_cost_cents])
        ], style: [nil, nil, nil, nil, nil, styles[:money]]
      end

      def cents_to_units(cents)
        cents.to_i / 100.0
      end
    end
  end
end

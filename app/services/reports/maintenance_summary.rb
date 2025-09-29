module Reports
  class MaintenanceSummary
    def initialize(from:, to:, vehicle_id: nil)
      @from       = parse_date(from) || Date.new(1900, 1, 1)
      @to         = parse_date(to)   || Date.current
      @vehicle_id = vehicle_id
    end

    def call
      scope = scoped
      {
        totals: totals_for(scope),
        breakdown_by_status: breakdown_by_status_for(scope),
        breakdown_by_vehicle: breakdown_by_vehicle_for(scope),
        top_vehicles_by_cost: top_vehicles_by_cost_for(scope, 3)
      }
    end

    private

    def scoped
      s = MaintenanceService.where(date: @from..@to)
      s = s.where(vehicle_id: @vehicle_id) if @vehicle_id.present?
      s
    end

    def totals_for(scope)
      { orders_count: scope.count, total_cost_cents: scope.sum(:cost_cents).to_i }
    end

    def breakdown_by_status_for(scope)
      scope
        .select(Arel.sql('status AS key, COUNT(*) AS services_count, SUM(cost_cents) AS total_cost_cents'))
        .group('status').order(:status)
        .map { |row| row_for_status(row) }
    end

    def breakdown_by_vehicle_for(scope)
      rows = scope
             .joins(:vehicle)
             .select(Arel.sql(select_vehicle_fields))
             .group('vehicle_id', 'vehicles.brand', 'vehicles.model', 'vehicles.plate')
             .order(:vehicle_id)
      rows.map { |row| row_for_vehicle(row) }
    end

    def top_vehicles_by_cost_for(scope, limit)
      rows = scope
             .joins(:vehicle)
             .select(Arel.sql(select_vehicle_sum_fields))
             .group('vehicle_id', 'vehicles.brand', 'vehicles.model', 'vehicles.plate')
             .order(Arel.sql('SUM(cost_cents) DESC'))
             .limit(limit)
      rows.map { |row| row_for_vehicle(row) }
    end

    # ---- helpers de SELECT para acortar métodos ----
    def select_vehicle_fields
      <<~SQL.squish
        vehicle_id,
        vehicles.brand,
        vehicles.model,
        vehicles.plate,
        COUNT(*) AS services_count,
        SUM(cost_cents) AS total_cost_cents
      SQL
    end

    def select_vehicle_sum_fields
      <<~SQL.squish
        vehicle_id,
        vehicles.brand,
        vehicles.model,
        vehicles.plate,
        SUM(cost_cents) AS total_cost_cents,
        COUNT(*) AS services_count
      SQL
    end

    # -------- Row builders --------
    def row_for_status(row)
      {
        key: status_name(row['key']),
        services_count: row['services_count'].to_i,
        total_cost_cents: row['total_cost_cents'].to_i
      }
    end

    def row_for_vehicle(row)
      {
        vehicle_id: row['vehicle_id'].to_i,
        brand: row['brand'],
        model: row['model'],
        plate: row['plate'],
        services_count: row['services_count'].to_i,
        total_cost_cents: row['total_cost_cents'].to_i
      }
    end

    # -------- Helpers --------
    def status_name(value)
      @status_mapping ||= MaintenanceService.statuses.invert.transform_keys(&:to_i)
      @status_mapping[value.to_i] || value.to_s
    end

    def parse_date(str)
      return nil if str.blank?

      Date.parse(str)
    rescue ArgumentError
      nil
    end
  end
end

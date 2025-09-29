# frozen_string_literal: true

module Api
  module V1
    class MaintenanceServicesController < BaseController
      include Pagination
      include Sortable

      SORTABLE_FIELDS = %w[date status priority cost_cents created_at].freeze

      before_action :set_vehicle, only: %i[index create]
      before_action :set_ms, only: %i[show update destroy]

      # GET /api/v1/vehicles/:vehicle_id/maintenance_services
      def index
        scope = apply_sort(filtered_scope)
        pagy, records = pagy(scope, items: params[:items].presence || Pagy::DEFAULT[:items])

        payload = PaginatedResource.new(collection: records, meta: pagy_metadata(pagy))

        render json: payload,
               serializer: PaginateSerializer,
               each_custom_serializer: MaintenanceServiceSerializer, # 👈 cambio clave
               adapter: :attributes,
               params: params,
               status: :ok
      end

      # GET /api/v1/maintenance_services/:id
      def show
        render json: @ms,
               serializer: MaintenanceServiceSerializer,
               adapter: :attributes,
               status: :ok
      end

      # POST /api/v1/vehicles/:vehicle_id/maintenance_services
      def create
        ms = @vehicle.maintenance_services.new(ms_params)
        if ms.save
          render json: ms,
                 serializer: MaintenanceServiceSerializer,
                 adapter: :attributes,
                 status: :created
        else
          render_validation_error(ms)
        end
      end

      # PATCH/PUT /api/v1/maintenance_services/:id
      def update
        if @ms.update(ms_params)
          render json: @ms,
                 serializer: MaintenanceServiceSerializer,
                 adapter: :attributes,
                 status: :ok
        else
          render_validation_error(@ms)
        end
      end

      # DELETE /api/v1/maintenance_services/:id
      def destroy
        @ms.destroy!
        head :no_content
      end

      private

      def set_vehicle
        @vehicle = Vehicle.find(params[:vehicle_id])
      end

      def set_ms
        @ms = MaintenanceService.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :no_content
      end

      def ms_params
        params.require(:maintenance_service).permit(
          :description, :status, :date, :cost_cents, :priority, :completed_at
        )
      end

      # ---- Filtrado y rango de fechas ----
      def filtered_scope
        @vehicle.maintenance_services
                .then { |s| apply_basic_filters(s) }
                .then { |s| apply_date_filter(s) }
      end

      def apply_basic_filters(scope)
        fp = filter_params
        scope = scope.where(status: fp[:status])     if fp[:status]
        scope = scope.where(priority: fp[:priority]) if fp[:priority]
        scope
      end

      def apply_date_filter(scope)
        from, to = filter_range
        return scope unless from || to

        scope.where(date: (from || Date.new(1900, 1, 1))..(to || Date.current))
      end

      def filter_params
        {
          status: params[:status].presence,
          priority: params[:priority].presence,
          from: params[:from].presence,
          to: params[:to].presence
        }
      end

      def filter_range
        [safe_date(filter_params[:from]), safe_date(filter_params[:to])]
      end

      def safe_date(str)
        return nil if str.blank?

        Date.parse(str)
      rescue ArgumentError
        nil
      end
    end
  end
end

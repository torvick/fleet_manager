# frozen_string_literal: true

module Api
  module V1
    class MaintenanceServicesController < BaseController
      include Pagination
      include Sortable
      include MaintenanceServicesFiltering

      SORTABLE_FIELDS = %w[date status priority cost_cents created_at].freeze
      SERIALIZER      = MaintenanceServiceSerializer

      before_action :set_vehicle, only: %i[index create]
      before_action :set_ms,      only: %i[show update destroy]

      # GET /api/v1/vehicles/:vehicle_id/maintenance_services
      def index
        authorize MaintenanceService
        scope = apply_sort(filtered_scope_for(@vehicle))
        pagy, records = pagy(scope, limit: params[:items]&.to_i || Pagy::DEFAULT[:items])

        payload = PaginatedResource.new(collection: records, meta: pagy_metadata(pagy))
        render json: payload,
               serializer: PaginateSerializer,
               each_custom_serializer: SERIALIZER,
               adapter: :attributes,
               params: params,
               status: :ok
      end

      # GET /api/v1/maintenance_services/:id
      def show
        authorize @ms
        render json: @ms, serializer: SERIALIZER, adapter: :attributes, status: :ok
      end

      # POST /api/v1/vehicles/:vehicle_id/maintenance_services
      def create
        ms = @vehicle.maintenance_services.new(ms_params)
        authorize ms
        if ms.save
          render json: ms, serializer: SERIALIZER, adapter: :attributes, status: :created
        else
          render_validation_error(ms)
        end
      end

      # PATCH/PUT /api/v1/maintenance_services/:id
      def update
        authorize @ms
        if @ms.update(ms_params)
          render json: @ms, serializer: SERIALIZER, adapter: :attributes, status: :ok
        else
          render_validation_error(@ms)
        end
      end

      # DELETE /api/v1/maintenance_services/:id
      def destroy
        authorize @ms
        @ms.discard
        head :no_content
      end

      # POST /api/v1/maintenance_services/:id/restore
      def restore
        @ms = MaintenanceService.with_discarded.find(params[:id])
        authorize @ms, :restore?
        @ms.undiscard
        render json: @ms, serializer: SERIALIZER, adapter: :attributes, status: :ok
      rescue ActiveRecord::RecordNotFound
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
    end
  end
end

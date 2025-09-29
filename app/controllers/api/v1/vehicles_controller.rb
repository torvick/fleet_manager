# frozen_string_literal: true

module Api
  module V1
    class VehiclesController < BaseController
      include Pagination
      include Sortable

      SORTABLE_FIELDS = %w[brand model year status vin plate created_at].freeze
      before_action :set_vehicle, only: %i[show update destroy]

      # GET /api/v1/vehicles
      def index
        authorize Vehicle
        scope = apply_sort(filter_scope(policy_scope(Vehicle)))
        pagy, records = pagy(scope, items: params[:items].presence || Pagy::DEFAULT[:items])

        payload = PaginatedResource.new(collection: records, meta: pagy_metadata(pagy))

        render json: payload,
               serializer: PaginateSerializer,
               each_custom_serializer: VehicleSerializer,
               adapter: :attributes,
               params: params,
               status: :ok
      end

      # GET /api/v1/vehicles/:id
      def show
        authorize @vehicle
        render json: @vehicle,
               serializer: VehicleSerializer,
               adapter: :attributes,
               status: :ok
      end

      # POST /api/v1/vehicles
      def create
        vehicle = Vehicle.new(vehicle_params)
        authorize vehicle
        if vehicle.save
          render json: vehicle,
                 serializer: VehicleSerializer,
                 adapter: :attributes,
                 status: :created
        else
          render_validation_error(vehicle)
        end
      end

      # PATCH/PUT /api/v1/vehicles/:id
      def update
        authorize @vehicle
        if @vehicle.update(vehicle_params)
          render json: @vehicle,
                 serializer: VehicleSerializer,
                 adapter: :attributes,
                 status: :ok
        else
          render_validation_error(@vehicle)
        end
      end

      # DELETE /api/v1/vehicles/:id
      def destroy
        authorize @vehicle
        @vehicle.destroy!
        head :no_content
      end

      private

      def set_vehicle
        @vehicle = Vehicle.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        head :no_content
      end

      def vehicle_params
        params.require(:vehicle).permit(:vin, :plate, :brand, :model, :year, :status)
      end

      # ---- Filtros de index ----
      def filter_scope(scope)
        scope = scope.search(params[:q])
        scope = scope.by_status(params[:status])
        scope = scope.by_brand(params[:brand])
        scope.by_year(params[:year])
      end
    end
  end
end

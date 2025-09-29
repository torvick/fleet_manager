# frozen_string_literal: true

module Web
  class VehiclesController < ApplicationController
    include Pagy::Backend

    before_action :set_vehicle, only: %i[show edit update destroy]
    before_action :set_discarded_vehicle, only: %i[restore]

    def index
      scope = Vehicle.kept
      scope = scope.search(params[:q])
      scope = scope.by_status(params[:status])
      scope = scope.by_brand(params[:brand])
      scope = scope.by_year(params[:year])

      @pagy, @vehicles = pagy(scope.order(created_at: :desc), limit: 10)
    end

    def show
      @vehicle = Vehicle.find(params[:id])
      @show_discarded = params[:show_discarded] == 'true'

      @services = if @show_discarded
                    @vehicle.maintenance_services.with_discarded.discarded.order(discarded_at: :desc).limit(10)
                  else
                    @vehicle.maintenance_services.order(date: :desc).limit(10)
                  end
    end

    def new
      @vehicle = Vehicle.new
    end

    def edit; end

    def create
      @vehicle = Vehicle.new(vehicle_params)
      if @vehicle.save
        redirect_to vehicle_path(@vehicle), notice: t('vehicle.create.success').to_s
      else
        flash.now[:alert] = @vehicle.errors.full_messages.to_sentence
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @vehicle.update(vehicle_params)
        redirect_to @vehicle, notice: t('vehicle.update.success').to_s
      else
        flash.now[:alert] = @vehicle.errors.full_messages.to_sentence
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @vehicle.discard
      redirect_to vehicles_path, notice: t('vehicle.destroy.success').to_s
    end

    def discarded
      scope = apply_filters_to_discarded_vehicles
      @pagy, @vehicles = pagy(scope.order(discarded_at: :desc), limit: 10)
      render :index
    end

    def restore
      @vehicle.undiscard
      redirect_to vehicle_path(@vehicle), notice: t('vehicle.restore.success').to_s
    end

    private

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    def set_discarded_vehicle
      @vehicle = Vehicle.with_discarded.find(params[:id])
    end

    def vehicle_params
      params.require(:vehicle).permit(:vin, :plate, :brand, :model, :year, :status)
    end

    def apply_filters_to_discarded_vehicles
      scope = Vehicle.discarded
      scope = scope.search(params[:q])
      scope = scope.by_status(params[:status])
      scope = scope.by_brand(params[:brand])
      scope.by_year(params[:year])
    end
  end
end

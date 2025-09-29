# frozen_string_literal: true

module Web
  class VehiclesController < ApplicationController
    include Pagy::Backend

    before_action :set_vehicle, only: %i[show edit update destroy]

    def index
      scope = Vehicle.all
      scope = scope.search(params[:q])
      scope = scope.by_status(params[:status])
      scope = scope.by_brand(params[:brand])
      scope = scope.by_year(params[:year])

      @pagy, @vehicles = pagy(scope.order(created_at: :desc), limit: 10)
    end

    def show
      @vehicle = Vehicle.includes(:maintenance_services).find(params[:id])
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
      @vehicle.destroy!
      redirect_to vehicles_path, notice: t('vehicle.destroy.success').to_s
    end

    private

    def set_vehicle
      @vehicle = Vehicle.find(params[:id])
    end

    def vehicle_params
      params.require(:vehicle).permit(:vin, :plate, :brand, :model, :year, :status)
    end
  end
end

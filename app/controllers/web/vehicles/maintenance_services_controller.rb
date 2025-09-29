# frozen_string_literal: true

module Web
  module Vehicles
    class MaintenanceServicesController < ApplicationController
      before_action :set_vehicle
      before_action :set_ms, only: %i[edit update destroy]
      before_action :set_discarded_ms, only: %i[restore]

      def new
        @maintenance_service = @vehicle.maintenance_services.new(date: Date.current)
      end

      def edit; end

      def create
        @maintenance_service = @vehicle.maintenance_services.new(ms_params)
        if @maintenance_service.save
          redirect_to @vehicle, notice: t('maintenance_service.create.success').to_s
        else
          flash.now[:alert] = @maintenance_service.errors.full_messages.to_sentence
          render :new, status: :unprocessable_content
        end
      end

      def update
        if @maintenance_service.update(ms_params)
          redirect_to  @vehicle, notice: t('maintenance_service.update.success').to_s
        else
          flash.now[:alert] = @maintenance_service.errors.full_messages.to_sentence
          render :edit, status: :unprocessable_content
        end
      end

      def destroy
        @maintenance_service.discard
        redirect_to @vehicle, notice: t('maintenance_service.destroy.success').to_s
      end

      def restore
        @maintenance_service.undiscard
        redirect_to @vehicle, notice: t('maintenance_service.restore.success').to_s
      end

      private

      def set_vehicle
        @vehicle = Vehicle.find(params[:vehicle_id])
      end

      def set_ms
        @maintenance_service = @vehicle.maintenance_services.find(params[:id])
      end

      def set_discarded_ms
        @maintenance_service = @vehicle.maintenance_services.with_discarded.find(params[:id])
      end

      def ms_params
        params.require(:maintenance_service).permit(
          :description, :status, :date, :cost_cents, :priority, :completed_at
        )
      end
    end
  end
end

class MaintenanceService < ApplicationRecord
  include Discard::Model

  belongs_to :vehicle, inverse_of: :maintenance_services

  enum :status, {
    pending: 0,
    in_progress: 1,
    completed: 2
  }, prefix: true

  enum :priority, {
    low: 0,
    medium: 1,
    high: 2
  }, prefix: true

  validates :description, presence: true
  validates :date, presence: true
  validates :cost_cents, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :priority, presence: true
  validates :status, presence: true

  validate  :date_cannot_be_in_future
  validate  :completed_requires_timestamp

  after_commit :refresh_vehicle_status, on: %i[create update]

  private

  def date_cannot_be_in_future
    return if date.blank?

    errors.add(:date, 'no puede ser futura') if date > Time.zone.today
  end

  def completed_requires_timestamp
    return unless status_completed?

    errors.add(:completed_at, 'debe estar presente si el status es completed') if completed_at.blank?
  end

  def refresh_vehicle_status
    VehicleStatusRefresher.call(vehicle_id)
  end
end

class VehiclePolicy < ApplicationPolicy
  def index?
    user.role_viewer? || user.role_manager? || user.role_admin?
  end

  def show?
    index?
  end

  def create?
    user.role_manager? || user.role_admin?
  end

  def new?
    create?
  end

  def update?
    user.role_manager? || user.role_admin?
  end

  def edit?
    update?
  end

  def destroy?
    user.role_admin?
  end

  def restore?
    user.role_admin?
  end

  class Scope < Scope
    def resolve
      scope.all
    end
  end

  private

  def vehicle_has_active_services?
    record.maintenance_services.exists?(status: %w[pending in_progress])
  end
end

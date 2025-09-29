# frozen_string_literal: true

module MaintenanceServicesFiltering
  extend ActiveSupport::Concern

  private

  def filtered_scope_for(vehicle)
    vehicle.maintenance_services
           .then { |s| apply_discard_filter(s) }
           .then { |s| apply_basic_filters(s) }
           .then { |s| apply_date_filter(s) }
  end

  def apply_discard_filter(scope)
    if params[:include_discarded] == 'true' && current_user.role_admin?
      scope.with_discarded
    elsif params[:only_discarded] == 'true' && current_user.role_admin?
      scope.with_discarded.discarded
    else
      scope
    end
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

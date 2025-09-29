module Sortable
  extend ActiveSupport::Concern

  def apply_sort(scope)
    sort = params[:sort].to_s
    return scope.order(id: :asc) if sort.blank?

    orders = sort.split(',').filter_map do |part|
      dir = part.start_with?('-') ? :desc : :asc
      field = part.delete_prefix('-')
      self.class::SORTABLE_FIELDS.include?(field) ? { field => dir } : nil
    end

    orders.any? ? scope.order(orders.reduce(&:merge)) : scope.order(id: :asc)
  end
end

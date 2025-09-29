module ApplicationHelper
  include Pagy::Frontend

  def vehicle_status_badge_class(status)
    map = {
      'active' => 'text-bg-success',
      'inactive' => 'text-bg-secondary',
      'service' => 'text-bg-info',
      'blocked' => 'text-bg-danger'
    }
    map[status.to_s] || 'text-bg-light'
  end

  # Devuelve 'is-invalid' si el campo tiene errores
  def invalid_class(record, field)
    record.errors[field].present? ? 'is-invalid' : ''
  end

  # Renderiza el bloque de errores del campo
  def field_error(record, field)
    return ''.html_safe if record.errors[field].blank?

    content_tag(:div, record.errors[field].join(', '), class: 'invalid-feedback')
  end

  def maintenance_status_badge(status)
    map = {
      'scheduled' => 'text-bg-secondary',
      'in_progress' => 'text-bg-info',
      'completed' => 'text-bg-success',
      'cancelled' => 'text-bg-danger'
    }
    map[status.to_s] || 'text-bg-light'
  end

  def priority_badge(priority)
    map = {
      'low' => 'text-bg-success',
      'medium' => 'text-bg-warning',
      'high' => 'text-bg-danger'
    }
    map[priority.to_s] || 'text-bg-secondary'
  end

  # Convierte centavos a moneda
  def money_cents(cents)
    number_to_currency((cents || 0).to_i / 100.0)
  end
end

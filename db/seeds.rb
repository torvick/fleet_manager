# db/seeds.rb
require 'faker'

Rails.logger.info '== Seeding =='

# -------------------------------------------------
# Config
# -------------------------------------------------
BRANDS_MODELS = {
  'Toyota' => %w[Corolla Camry Hilux Yaris RAV4 Prius Avanza],
  'Ford' => %w[Focus Fiesta Ranger Explorer Mustang Escape],
  'Nissan' => %w[Sentra Versa March Frontier Altima X-Trail],
  'Chevrolet' => %w[Aveo Onix Tracker Captiva Silverado Spark],
  'Volkswagen' => %w[Jetta Virtus Taos Golf Vento Tiguan],
  'Hyundai' => %w[Elantra Accent Tucson Creta i10 Kona],
  'Kia' => %w[Rio Forte Sportage Seltos Soul Cerato],
  'Honda' => %w[Civic City CR-V HR-V Fit Accord]
}.freeze

VEHICLE_COUNT        = 50
SERVICES_PER_VEHICLE = 1..3
SERVICE_DAYS_BACK    = 180
CENTS_RANGE          = 2_000..100_000 # $20 – $1000

# Enums reales
VEHICLE_STATUSES = Vehicle.statuses.keys.map(&:to_sym) # [:active, :inactive, :in_maintenance]
MS_STATUSES      = MaintenanceService.statuses.keys.map(&:to_sym) # [:pending, :in_progress, :completed]
MS_PRIORITIES    = MaintenanceService.priorities.keys.map(&:to_sym) # [:low, :medium, :high]

def random_weighted(keys)
  keys.sample # simple y seguro, podrías hacer pesos si quieres
end

def unique_vin!
  loop do
    vin = Faker::Vehicle.vin
    return vin unless Vehicle.exists?(vin: vin)
  end
end

def mx_plate
  letters = ('A'..'Z').to_a.sample(3).join
  numbers = rand(100..999)
  suffix  = ('A'..'Z').to_a.sample
  "#{letters}#{numbers}#{suffix}"
end

def money_cents
  rand(CENTS_RANGE)
end

# -------------------------------------------------
# Usuarios demo
# -------------------------------------------------
users_data = [
  { email: 'admin@example.com',   password: 'password123', role: :admin },
  { email: 'manager@example.com', password: 'password123', role: :manager },
  { email: 'viewer@example.com',  password: 'password123', role: :viewer }
]

users_data.each do |attrs|
  user = User.find_or_initialize_by(email: attrs[:email])
  if user.new_record?
    user.assign_attributes(attrs)
    user.save!
    Rails.logger.info "User #{attrs[:email]} creado (#{attrs[:role]}) – pass: password123"
  else
    user.update!(role: attrs[:role]) unless user.role.to_s == attrs[:role].to_s
  end
end

# -------------------------------------------------
# Vehículos + servicios
# -------------------------------------------------
Vehicle.delete_all
MaintenanceService.delete_all

VEHICLE_COUNT.times do
  brand  = BRANDS_MODELS.keys.sample
  model  = BRANDS_MODELS[brand].sample
  year   = rand(2010..Time.zone.today.year)
  status = random_weighted(VEHICLE_STATUSES)

  v = Vehicle.create!(
    vin: unique_vin!,
    plate: mx_plate,
    brand: brand,
    model: model,
    year: year,
    status: status
  )

  rand(SERVICES_PER_VEHICLE).times do
    st = random_weighted(MS_STATUSES)
    dt = Faker::Date.between(from: SERVICE_DAYS_BACK.days.ago, to: Date.current)

    attrs = {
      vehicle: v,
      description: Faker::Vehicle.standard_specs.sample,
      status: st,
      date: dt,
      cost_cents: money_cents,
      priority: random_weighted(MS_PRIORITIES)
    }
    attrs[:completed_at] = Faker::Time.between(from: dt.to_time, to: Time.zone.now) if st == :completed

    MaintenanceService.create!(attrs)
  end
end

Rails.logger.info "Vehicles: #{Vehicle.count}"
Rails.logger.info "MaintenanceServices: #{MaintenanceService.count}"
Rails.logger.info '== Seeds done =='

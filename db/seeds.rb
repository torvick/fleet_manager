require 'faker'

Rails.logger.debug 'Seeding...'

if User.where(email: 'admin@example.com').none?
  User.create!(email: 'admin@example.com', password: 'password123', role: 'admin')
  Rails.logger.debug 'User admin@example.com created (password: password123)'
end

MaintenanceService.delete_all
Vehicle.delete_all

brands = %w[Toyota Ford Nissan Chevrolet Volkswagen Hyundai Kia Honda]
models = %w[Corolla Focus Sentra Aveo Jetta Elantra Rio Civic]

vehicles = 50.times.map do
  Vehicle.create!(
    vin: Faker::Vehicle.vin,
    plate: Faker::Vehicle.license_plate.gsub('-', '').upcase,
    brand: brands.sample,
    model: models.sample,
    year: rand(2012..2025),
    status: :active
  )
end

def random_cost
  rand(2_000..100_000) # centavos
end

100.times do
  v = vehicles.sample
  st = %i[pending in_progress completed].sample
  dt = Faker::Date.between(from: 120.days.ago, to: Time.zone.today)

  attrs = {
    vehicle: v,
    description: Faker::Vehicle.standard_specs.sample,
    status: st,
    date: dt,
    cost_cents: random_cost,
    priority: %i[low medium high].sample
  }

  attrs[:completed_at] = Faker::Time.between(from: dt.to_time, to: Time.zone.now) if st == :completed

  MaintenanceService.create!(attrs)
end

Rails.logger.debug { "Vehicles: #{Vehicle.count}" }
Rails.logger.debug { "MaintenanceServices: #{MaintenanceService.count}" }
Rails.logger.debug 'Done.'

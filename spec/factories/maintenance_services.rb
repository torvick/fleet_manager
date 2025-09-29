FactoryBot.define do
  factory :maintenance_service do
    vehicle
    description { 'Cambio de aceite' }
    status { :pending }
    date { Time.zone.today }
    cost_cents { 1_000 }
    priority { :medium }

    trait :completed do
      status { :completed }
      completed_at { 1.hour.ago }
    end
  end
end

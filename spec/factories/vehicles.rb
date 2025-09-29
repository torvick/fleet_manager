FactoryBot.define do
  factory :vehicle do
    vin   { SecureRandom.hex(8).upcase }
    plate { "#{('A'..'Z').to_a.sample(3).join}#{rand(100..999)}" }
    brand { %w[Toyota Ford Nissan].sample }
    model { %w[Corolla Focus Sentra].sample }
    year  { rand(2015..2025) }
    status { :active }
  end
end

FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    role { :admin }

    trait :admin do
      role { :admin }
    end

    trait :manager do
      role { :manager }
    end

    trait :viewer do
      role { :viewer }
    end
  end
end

FactoryBot.define do
  factory :badge do
    association :organisation
    name          { Faker::Lorem.words(number: 2).join(" ").titleize }
    description   { Faker::Lorem.sentence }
    criteria_type { "hours_reached" }
    criteria_value { 100 }

    trait :manual do
      criteria_type  { "manual" }
      criteria_value { nil }
    end

    trait :consecutive_months do
      criteria_type  { "consecutive_months" }
      criteria_value { 3 }
    end

    trait :system_badge do
      organisation { nil }
    end
  end
end

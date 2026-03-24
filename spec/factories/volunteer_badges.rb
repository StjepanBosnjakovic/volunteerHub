FactoryBot.define do
  factory :volunteer_badge do
    association :volunteer_profile
    association :badge
    awarded_at { Time.current }
    awarded_by { nil }  # auto-awarded

    trait :manual do
      association :awarded_by, factory: :user
    end
  end
end

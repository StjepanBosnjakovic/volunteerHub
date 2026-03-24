FactoryBot.define do
  factory :notification do
    association :recipient, factory: :user
    association :organisation
    notification_type { "shift_reminder" }
    data { { shift_title: "Community Garden", shift_date: 2.days.from_now.to_s } }
    read_at { nil }

    trait :read do
      read_at { 1.hour.ago }
    end

    trait :hour_approved do
      notification_type { "hour_approved" }
      data { { hours: "4.5", program_name: "Green Spaces" } }
    end

    trait :milestone_reached do
      notification_type { "milestone_reached" }
      data { { milestone_label: "50 Hours Champion" } }
    end

    trait :announcement do
      notification_type { "announcement" }
      data { { title: "Important Update", announcement_id: 1 } }
    end
  end
end

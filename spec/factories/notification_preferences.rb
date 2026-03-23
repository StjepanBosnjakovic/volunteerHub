FactoryBot.define do
  factory :notification_preference do
    association :user
    notification_type { "shift_reminder" }
    in_app { true }
    email  { true }
  end
end

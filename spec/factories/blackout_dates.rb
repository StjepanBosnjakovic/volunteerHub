FactoryBot.define do
  factory :blackout_date do
    volunteer_profile { nil }
    start_date { "2026-03-22" }
    end_date { "2026-03-22" }
    reason { "MyString" }
  end
end

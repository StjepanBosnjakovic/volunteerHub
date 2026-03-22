FactoryBot.define do
  factory :availability do
    volunteer_profile { nil }
    day_of_week { 1 }
    time_blocks { "" }
  end
end

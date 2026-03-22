FactoryBot.define do
  factory :credential do
    volunteer_profile { nil }
    name { "MyString" }
    credential_type { "MyString" }
    expires_at { "2026-03-22" }
    notes { "MyText" }
  end
end

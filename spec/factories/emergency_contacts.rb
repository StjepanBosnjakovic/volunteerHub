FactoryBot.define do
  factory :emergency_contact do
    volunteer_profile { nil }
    name { "MyString" }
    relationship { "MyString" }
    phone { "MyString" }
    email { "MyString" }
  end
end

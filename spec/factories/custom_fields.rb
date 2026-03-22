FactoryBot.define do
  factory :custom_field do
    organisation { nil }
    field_type { "MyString" }
    label { "MyString" }
    options { "" }
    required { false }
    position { 1 }
  end
end

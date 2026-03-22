FactoryBot.define do
  factory :custom_field_value do
    custom_field { nil }
    value { "MyText" }
    customizable { nil }
  end
end

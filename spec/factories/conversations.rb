FactoryBot.define do
  factory :conversation do
    association :organisation
    conversation_type { :direct }
    title { nil }

    trait :group_chat do
      conversation_type { :group_chat }
      title { Faker::Lorem.words(number: 3).join(" ") }
    end
  end
end

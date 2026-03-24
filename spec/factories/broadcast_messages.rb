FactoryBot.define do
  factory :broadcast_message do
    association :organisation
    association :sender, factory: :user
    subject          { Faker::Lorem.sentence(word_count: 4) }
    body             { Faker::Lorem.paragraph }
    channel          { :in_app }
    status           { :draft }
    segment_filters  { {} }

    trait :email_channel do
      channel { :email }
    end

    trait :sent do
      status          { :sent }
      recipient_count { 30 }
      sent_at         { 1.hour.ago }
    end
  end
end

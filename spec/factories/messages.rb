FactoryBot.define do
  factory :message do
    association :conversation
    association :sender, factory: :user
    message_type { :text }

    after(:build) do |message|
      message.body = Faker::Lorem.sentence
    end
  end
end

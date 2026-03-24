FactoryBot.define do
  factory :announcement do
    association :organisation
    association :author, factory: :user
    title  { Faker::Lorem.sentence(word_count: 5) }
    status { :draft }

    after(:build) do |announcement|
      announcement.body = Faker::Lorem.paragraph(sentence_count: 3)
    end

    trait :published do
      status       { :published }
      published_at { 1.day.ago }
    end

    trait :scheduled do
      status        { :scheduled }
      scheduled_for { 2.days.from_now }
    end
  end
end

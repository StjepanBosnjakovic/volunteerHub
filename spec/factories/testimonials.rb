FactoryBot.define do
  factory :testimonial do
    association :volunteer_profile
    association :organisation
    quote         { Faker::Lorem.sentence(word_count: 15) }
    published     { false }
    consent_given { true }

    trait :published do
      published    { true }
      published_at { 1.day.ago }
    end

    trait :no_consent do
      consent_given { false }
    end
  end
end

FactoryBot.define do
  factory :email_campaign do
    association :organisation
    association :sender, factory: :user
    name      { Faker::Lorem.words(number: 3).join(" ").capitalize }
    subject_a { Faker::Lorem.sentence }
    body_html { "<p>#{Faker::Lorem.paragraph}</p>" }
    channel   { "email" }
    status    { :draft }

    trait :sent do
      status          { :sent }
      recipient_count { 50 }
      sent_at         { 1.day.ago }
    end

    trait :ab_test do
      subject_b { Faker::Lorem.sentence }
    end
  end
end

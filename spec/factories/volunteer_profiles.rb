FactoryBot.define do
  factory :volunteer_profile do
    association :organisation
    association :user
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    preferred_name { nil }
    pronouns { nil }
    date_of_birth { 25.years.ago.to_date }
    phone { Faker::PhoneNumber.phone_number }
    bio { Faker::Lorem.paragraph }
    status { :active }
    max_hours_per_week { 20 }
    max_hours_per_month { 80 }
    is_minor { false }
    policy_accepted_at { 1.week.ago }

    trait :pending do
      status { :pending }
    end

    trait :inactive do
      status { :inactive }
    end

    trait :minor do
      date_of_birth { 16.years.ago.to_date }
      is_minor { true }
    end
  end
end

FactoryBot.define do
  factory :organisation do
    sequence(:name) { |n| "#{Faker::Company.name} #{n}" }
    slug { nil } # auto-generated from name
    primary_colour { "#4F46E5" }
    timezone { "UTC" }
    locale { "en" }
    email_sender_name { "VolunteerOS" }
    email_sender_address { Faker::Internet.email }
    setup_complete { true }

    trait :not_set_up do
      setup_complete { false }
    end
  end
end

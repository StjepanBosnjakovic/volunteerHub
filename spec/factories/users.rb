FactoryBot.define do
  factory :user do
    association :organisation
    email { Faker::Internet.unique.email }
    password { "Password1!" }
    password_confirmation { "Password1!" }
    confirmed_at { Time.current }
    role { :volunteer }

    trait :super_admin do
      role { :super_admin }
    end

    trait :coordinator do
      role { :coordinator }
    end

    trait :read_only_staff do
      role { :read_only_staff }
    end

    trait :volunteer do
      role { :volunteer }
    end
  end
end

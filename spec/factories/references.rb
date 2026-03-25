FactoryBot.define do
  factory :reference do
    association :volunteer_profile
    association :coordinator, factory: :user
    status        { :requested }
    notes         { Faker::Lorem.sentence }
    stats_snapshot { {} }

    trait :issued do
      status    { :issued }
      issued_at { Time.current }
      stats_snapshot do
        {
          "total_hours"     => 150,
          "shifts_attended" => 30,
          "badges_earned"   => 3,
          "programs"        => ["Community Outreach"],
          "snapshot_at"     => Time.current.iso8601
        }
      end
    end

    trait :declined do
      status { :declined }
    end
  end
end

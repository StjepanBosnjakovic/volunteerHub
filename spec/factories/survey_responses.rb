FactoryBot.define do
  factory :survey_response do
    association :survey
    association :volunteer_profile
    shift     { nil }
    answers   { { "0" => "8", "1" => "Great experience!" } }
    nps_score { 8 }
  end
end

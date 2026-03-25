FactoryBot.define do
  factory :survey do
    association :organisation
    title               { Faker::Lorem.sentence(word_count: 4) }
    trigger             { :post_shift }
    active              { true }
    grace_period_hours  { 1 }
    questions do
      [
        { "type" => "nps",  "label" => "How likely are you to recommend us? (0-10)" },
        { "type" => "text", "label" => "What did you enjoy most?" }
      ]
    end

    trait :inactive do
      active { false }
    end

    trait :pulse do
      trigger { :pulse }
    end

    trait :manual do
      trigger { :manual }
    end
  end
end

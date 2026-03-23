FactoryBot.define do
  factory :email_template do
    association :organisation
    event_type { "welcome" }
    subject    { "Welcome to {{org_name}}!" }
    body_html  { "<p>Hi {{volunteer_name}}, welcome!</p>" }
    active     { true }
  end
end

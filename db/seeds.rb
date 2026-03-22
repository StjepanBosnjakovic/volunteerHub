# Seed default organisation for development
org = Organisation.find_or_create_by!(slug: "demo-org") do |o|
  o.name = "Demo Organisation"
  o.primary_colour = "#4F46E5"
  o.timezone = "UTC"
  o.locale = "en"
  o.email_sender_name = "VolunteerOS"
  o.email_sender_address = "noreply@volunteeros.example.com"
end

puts "Organisation: #{org.name}"

# Create super admin
ActsAsTenant.with_tenant(org) do
  admin = User.find_or_create_by!(email: "admin@example.com") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.organisation = org
    u.role = :super_admin
    u.confirmed_at = Time.current
  end
  puts "Super admin: #{admin.email} / Password1!"

  # Create coordinator
  coordinator = User.find_or_create_by!(email: "coordinator@example.com") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.organisation = org
    u.role = :coordinator
    u.confirmed_at = Time.current
  end
  puts "Coordinator: #{coordinator.email} / Password1!"

  # Create a volunteer
  volunteer_user = User.find_or_create_by!(email: "volunteer@example.com") do |u|
    u.password = "Password1!"
    u.password_confirmation = "Password1!"
    u.organisation = org
    u.role = :volunteer
    u.confirmed_at = Time.current
  end

  VolunteerProfile.find_or_create_by!(user: volunteer_user) do |p|
    p.organisation = org
    p.first_name = "Jane"
    p.last_name = "Smith"
    p.phone = "+44 7700 900123"
    p.bio = "Passionate about community service."
    p.status = :active
    p.date_of_birth = 28.years.ago.to_date
    p.policy_accepted_at = 1.week.ago
  end
  puts "Volunteer: #{volunteer_user.email} / Password1!"

  # Seed skills
  %w[First\ Aid Driving Teaching IT Event\ Planning Fundraising].each do |skill_name|
    Skill.find_or_create_by!(name: skill_name, organisation: org)
  end

  # Seed interest categories
  %w[Health Education Environment Community\ Support Arts\ \&\ Culture].each do |cat_name|
    InterestCategory.find_or_create_by!(name: cat_name, organisation: org)
  end

  puts "Seeded #{Skill.count} skills and #{InterestCategory.count} interest categories"
end

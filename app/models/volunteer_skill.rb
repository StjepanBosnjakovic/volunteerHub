class VolunteerSkill < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :skill
end

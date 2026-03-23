class VolunteerMilestone < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :milestone

  validates :volunteer_profile, presence: true
  validates :milestone, presence: true
  validates :reached_at, presence: true
  validates :milestone_id, uniqueness: { scope: :volunteer_profile_id }
end

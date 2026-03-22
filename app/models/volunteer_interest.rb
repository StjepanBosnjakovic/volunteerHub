class VolunteerInterest < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :interest_category
end

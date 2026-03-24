class VolunteerBadge < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :badge
  belongs_to :awarded_by, class_name: "User", optional: true  # nil = auto-awarded

  validates :volunteer_profile, presence: true
  validates :badge,             presence: true
  validates :awarded_at,        presence: true
  validates :badge_id, uniqueness: { scope: :volunteer_profile_id,
                                     message: "has already been awarded to this volunteer" }

  scope :recent, -> { order(awarded_at: :desc) }

  def manual_award?
    awarded_by_id.present?
  end

  def linkedin_share_url
    text = "I just earned the '#{badge.name}' badge for my volunteer work!"
    "https://www.linkedin.com/sharing/share-offsite/?url=#{CGI.escape(text)}"
  end
end

class VolunteerApplication < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :opportunity

  has_many :application_answers, dependent: :destroy

  enum :status, {
    applied: 0,
    shortlisted: 1,
    approved: 2,
    declined: 3,
    waitlisted: 4
  }

  validates :volunteer_profile, presence: true
  validates :opportunity, presence: true
  validates :volunteer_profile_id, uniqueness: { scope: :opportunity_id, message: "has already applied to this opportunity" }

  after_save :promote_waitlist_if_spot_opened

  scope :ordered_by_position, -> { order(:position, :created_at) }

  private

  def promote_waitlist_if_spot_opened
    return unless saved_change_to_status?
    return unless %w[declined].include?(status)
    return if opportunity.full?

    next_waitlisted = opportunity.volunteer_applications
                                 .waitlisted
                                 .order(:position, :created_at)
                                 .first
    return unless next_waitlisted

    PromoteWaitlistJob.perform_later(next_waitlisted.id)
  end
end

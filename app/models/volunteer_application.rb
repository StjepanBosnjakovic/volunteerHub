class VolunteerApplication < ApplicationRecord
  belongs_to :volunteer_profile, optional: true
  belongs_to :opportunity

  has_many :application_answers, dependent: :destroy

  enum :status, {
    applied: 0,
    shortlisted: 1,
    approved: 2,
    declined: 3,
    waitlisted: 4
  }

  validates :opportunity, presence: true
  validates :volunteer_profile, presence: true, unless: -> { guest_email.present? }
  validates :guest_name, :guest_email, presence: true, unless: -> { volunteer_profile.present? }
  validates :guest_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :volunteer_profile_id, uniqueness: { scope: :opportunity_id, message: "has already applied to this opportunity" }, allow_nil: true
  validates :guest_email, uniqueness: { scope: :opportunity_id, message: "has already applied to this opportunity" }, allow_blank: true

  after_save :promote_waitlist_if_spot_opened

  scope :ordered_by_position, -> { order(:position, :created_at) }

  def generate_onboarding_token!
    loop do
      token = SecureRandom.urlsafe_base64(32)
      unless VolunteerApplication.exists?(onboarding_token: token)
        update_column(:onboarding_token, token)
        break
      end
    end
  end

  def onboarding_complete?
    onboarding_completed_at.present?
  end

  def needs_password_setup?
    volunteer_profile&.user&.encrypted_password.blank?
  end

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

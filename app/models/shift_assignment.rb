class ShiftAssignment < ApplicationRecord
  belongs_to :shift
  belongs_to :volunteer_profile
  belongs_to :shift_role, optional: true
  has_one :attendance, dependent: :destroy

  enum :status, { confirmed: 0, waitlisted: 1, cancelled: 2 }

  validates :shift, presence: true
  validates :volunteer_profile, presence: true
  validates :shift_id, uniqueness: { scope: :volunteer_profile_id, message: "already assigned to this shift" }

  after_update :check_waitlist_promotion, if: -> { saved_change_to_status? && cancelled? }

  scope :active, -> { where(status: %i[confirmed waitlisted]) }
  scope :confirmed, -> { where(status: :confirmed) }
  scope :waitlisted, -> { where(status: :waitlisted) }

  def cancel!(actor)
    late = shift.late_cancellation?(Time.current)
    update!(status: :cancelled, cancelled_at: Time.current, late_cancel: late)
  end

  private

  def check_waitlist_promotion
    next_waitlisted = shift.shift_assignments.waitlisted.order(:created_at).first
    return unless next_waitlisted
    return if shift.full?
    next_waitlisted.update!(status: :confirmed)
    # Notification would be queued here in Phase 5
  end
end

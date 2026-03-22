class SwapRequest < ApplicationRecord
  belongs_to :from_assignment, class_name: "ShiftAssignment"
  belongs_to :to_assignment, class_name: "ShiftAssignment", optional: true
  belongs_to :requested_by, class_name: "User"
  belongs_to :reviewed_by, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, declined: 2 }

  validates :from_assignment, presence: true
  validates :requested_by, presence: true

  scope :pending_review, -> { where(status: :pending) }

  def approve!(reviewer)
    transaction do
      # Swap the volunteer profiles between the two assignments
      if to_assignment.present?
        from_vol = from_assignment.volunteer_profile
        to_vol = to_assignment.volunteer_profile
        from_assignment.update!(volunteer_profile: to_vol)
        to_assignment.update!(volunteer_profile: from_vol)
      end
      update!(status: :approved, reviewed_by: reviewer, reviewed_at: Time.current)
    end
  end

  def decline!(reviewer)
    update!(status: :declined, reviewed_by: reviewer, reviewed_at: Time.current)
  end
end

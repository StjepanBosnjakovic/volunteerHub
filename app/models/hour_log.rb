class HourLog < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :volunteer_profile
  belongs_to :organisation
  belongs_to :program
  belongs_to :shift, optional: true
  belongs_to :attendance, optional: true
  belongs_to :approved_by, class_name: "User", optional: true

  enum :status, { pending: 0, approved: 1, rejected: 2 }
  enum :source, { auto: 0, self_logged: 1, bulk: 2 }

  validates :date, presence: true
  validates :hours, presence: true, numericality: { greater_than: 0, less_than_or_equal_to: 24 }
  validates :volunteer_profile, presence: true
  validates :program, presence: true

  scope :ordered, -> { order(date: :desc, created_at: :desc) }
  scope :for_volunteer, ->(vp) { where(volunteer_profile: vp) }
  scope :for_program, ->(program) { where(program: program) }
  scope :in_period, ->(from, to) { where(date: from..to) }
  scope :disputed, -> { where(disputed: true) }

  after_update :enqueue_milestone_check, if: -> { saved_change_to_status? && approved? }

  def approve!(by:)
    update!(status: :approved, approved_by: by, approved_at: Time.current)
  end

  def reject!(by:, reason: nil)
    update!(status: :rejected, approved_by: by, approved_at: Time.current, rejection_reason: reason)
  end

  def dispute!(note:)
    update!(disputed: true, dispute_note: note, status: :pending)
  end

  private

  def enqueue_milestone_check
    MilestoneCheckJob.perform_later(volunteer_profile_id)
  end
end

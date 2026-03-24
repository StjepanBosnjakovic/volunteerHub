class Announcement < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  belongs_to :author, class_name: "User"
  has_rich_text :body

  enum :status, { draft: 0, published: 1, scheduled: 2, archived: 3 }

  validates :title,  presence: true
  validates :author, presence: true

  scope :ordered,   -> { order(published_at: :desc, created_at: :desc) }
  scope :visible,   -> { where(status: :published).where("published_at <= ?", Time.current) }
  scope :scheduled, -> { where(status: :scheduled).where.not(scheduled_for: nil) }

  after_update :broadcast_feed_update, if: -> { saved_change_to_status? && published? }

  def publish!
    update!(status: :published, published_at: Time.current)
  end

  def schedule!(at:)
    update!(status: :scheduled, scheduled_for: at)
  end

  def archive!
    update!(status: :archived)
  end

  private

  def broadcast_feed_update
    Turbo::StreamsChannel.broadcast_prepend_to(
      "announcements_feed_#{organisation_id}",
      target:  "announcements_feed",
      partial: "announcements/announcement_card",
      locals:  { announcement: self }
    )
  end
end

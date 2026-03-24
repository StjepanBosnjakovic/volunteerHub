class Testimonial < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :volunteer_profile
  belongs_to :organisation

  validates :quote,             presence: true
  validates :volunteer_profile, presence: true
  validates :organisation,      presence: true

  scope :published,  -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :consented,  -> { where(consent_given: true) }
  scope :ordered,    -> { order(published_at: :desc, created_at: :desc) }

  def publish!
    update!(published: true, published_at: Time.current)
  end

  def unpublish!
    update!(published: false, published_at: nil)
  end
end

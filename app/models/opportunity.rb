class Opportunity < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :opportunity_skills, dependent: :destroy
  has_many :skills, through: :opportunity_skills
  has_many :volunteer_applications, dependent: :destroy

  has_many :application_questions, -> { order(:position) }, dependent: :destroy

  enum :status, { draft: 0, published: 1, closed: 2 }

  COMMITMENT_LEVELS = %w[one_time short_term ongoing flexible].freeze

  validates :title, presence: true
  validates :slug, presence: true, uniqueness: { scope: :organisation_id }
  validates :status, presence: true

  before_validation :generate_slug, if: -> { slug.blank? && title.present? }

  scope :published, -> { where(status: :published) }
  scope :upcoming, -> { where("starts_at > ?", Time.current) }
  scope :with_spots, -> { where("spots_available > 0") }

  def spots_remaining
    return nil if spots_available.nil?
    spots_available - volunteer_applications.where(status: %i[approved shortlisted]).count
  end

  def full?
    spots_remaining.present? && spots_remaining <= 0
  end

  def to_param
    slug
  end

  private

  def generate_slug
    base = title.parameterize
    self.slug = base
    counter = 1
    while Opportunity.where(organisation_id: organisation_id).where(slug: slug).where.not(id: id).exists?
      self.slug = "#{base}-#{counter}"
      counter += 1
    end
  end
end

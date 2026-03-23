class Organisation < ApplicationRecord
  has_many :users, dependent: :destroy
  has_many :volunteer_profiles, dependent: :destroy
  has_many :skills, dependent: :destroy
  has_many :interest_categories, dependent: :destroy
  has_many :custom_fields, dependent: :destroy
  has_many :opportunities, dependent: :destroy
  has_many :onboarding_checklists, dependent: :destroy
  has_many :milestones, dependent: :destroy
  has_many :hour_logs, dependent: :destroy

  # Phase 5 — Communications
  has_many :conversations,            dependent: :destroy
  has_many :notifications,            dependent: :destroy
  has_many :email_templates,          dependent: :destroy
  has_many :email_campaigns,          dependent: :destroy
  has_many :announcements,            dependent: :destroy
  has_many :broadcast_messages,       dependent: :destroy

  has_one_attached :logo

  validates :name, presence: true
  validates :slug, presence: true, uniqueness: true,
                   format: { with: /\A[a-z0-9\-]+\z/, message: "only lowercase letters, numbers, and hyphens" }
  validates :email_sender_address, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true

  before_validation :generate_slug, if: -> { slug.blank? && name.present? }

  private

  def generate_slug
    self.slug = name.parameterize
  end
end

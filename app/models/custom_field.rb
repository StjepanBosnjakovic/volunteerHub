class CustomField < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :custom_field_values, dependent: :destroy

  FIELD_TYPES = %w[text textarea select multiselect checkbox date number].freeze

  validates :label, presence: true
  validates :field_type, presence: true, inclusion: { in: FIELD_TYPES }

  scope :ordered, -> { order(:position) }
end

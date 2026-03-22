class ApplicationQuestion < ApplicationRecord
  belongs_to :opportunity
  has_many :application_answers, dependent: :destroy

  QUESTION_TYPES = %w[text multiple_choice file].freeze

  validates :label, presence: true
  validates :question_type, presence: true, inclusion: { in: QUESTION_TYPES }

  default_scope { order(:position) }
end

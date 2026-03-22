class OnboardingStep < ApplicationRecord
  belongs_to :onboarding_checklist
  has_many :volunteer_onboarding_progresses, dependent: :destroy
  has_one :quiz, dependent: :destroy

  STEP_TYPES = %w[video document quiz upload sign induction].freeze

  validates :title, presence: true
  validates :step_type, presence: true, inclusion: { in: STEP_TYPES }

  default_scope { order(:position) }

  def quiz_step?
    step_type == "quiz"
  end
end

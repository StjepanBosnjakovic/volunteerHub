class Quiz < ApplicationRecord
  belongs_to :onboarding_step
  has_many :quiz_questions, -> { order(:position) }, dependent: :destroy

  validates :passing_score, presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def score_for(volunteer_profile)
    return 0 if quiz_questions.empty?

    correct = QuizAnswer
      .joins(:quiz_question)
      .where(quiz_questions: { quiz_id: id })
      .where(volunteer_profile: volunteer_profile, correct: true)
      .count

    (correct.to_f / quiz_questions.count * 100).round
  end

  def passed_by?(volunteer_profile)
    score_for(volunteer_profile) >= passing_score
  end
end

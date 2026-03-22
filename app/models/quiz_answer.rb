class QuizAnswer < ApplicationRecord
  belongs_to :volunteer_profile
  belongs_to :quiz_question

  validates :volunteer_profile, presence: true
  validates :quiz_question, presence: true
  validates :volunteer_profile_id, uniqueness: { scope: :quiz_question_id }
end

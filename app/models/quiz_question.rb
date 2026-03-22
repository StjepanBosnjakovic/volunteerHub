class QuizQuestion < ApplicationRecord
  belongs_to :quiz
  has_many :quiz_answers, dependent: :destroy

  validates :question, presence: true
  validates :correct_answer, presence: true
end

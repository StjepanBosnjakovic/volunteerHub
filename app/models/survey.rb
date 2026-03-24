class Survey < ApplicationRecord
  acts_as_tenant :organisation

  belongs_to :organisation
  has_many :survey_responses, dependent: :destroy

  enum :trigger, { post_shift: 0, post_program: 1, pulse: 2, manual: 3 }

  validates :title,   presence: true
  validates :trigger, presence: true

  scope :active,   -> { where(active: true) }
  scope :ordered,  -> { order(:title) }

  # Returns the list of question hashes from the JSON column.
  # Each question: { "type" => "text|rating|nps|multiple_choice", "label" => "...", "options" => [...] }
  def question_list
    Array(questions)
  end

  def nps_question?
    question_list.any? { |q| q["type"] == "nps" }
  end

  def response_count
    survey_responses.count
  end

  def average_nps
    return nil unless nps_question?
    scores = survey_responses.where.not(nps_score: nil).pluck(:nps_score)
    return nil if scores.empty?
    (scores.sum.to_f / scores.size).round(1)
  end

  # NPS = % Promoters (9-10) - % Detractors (0-6)
  def net_promoter_score
    return nil unless nps_question?
    scores = survey_responses.where.not(nps_score: nil).pluck(:nps_score)
    return nil if scores.empty?

    promoters  = scores.count { |s| s >= 9 }
    detractors = scores.count { |s| s <= 6 }
    total      = scores.size

    ((promoters.to_f / total - detractors.to_f / total) * 100).round
  end
end

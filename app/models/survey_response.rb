class SurveyResponse < ApplicationRecord
  belongs_to :survey
  belongs_to :volunteer_profile
  belongs_to :shift, optional: true

  validates :survey,            presence: true
  validates :volunteer_profile, presence: true
  validates :survey_id, uniqueness: { scope: :volunteer_profile_id,
                                      message: "has already been completed by this volunteer" }

  before_save :extract_nps_score

  scope :recent,   -> { order(created_at: :desc) }
  scope :with_nps, -> { where.not(nps_score: nil) }

  private

  def extract_nps_score
    nps_q_index = survey.question_list.index { |q| q["type"] == "nps" }
    return unless nps_q_index

    raw = answers[nps_q_index.to_s] || answers[nps_q_index]
    self.nps_score = raw.to_i if raw.present?
  end
end

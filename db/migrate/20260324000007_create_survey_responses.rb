class CreateSurveyResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :survey_responses do |t|
      t.bigint  :survey_id,            null: false
      t.bigint  :volunteer_profile_id, null: false
      t.bigint  :shift_id                              # nullable — only set for post_shift surveys
      t.jsonb   :answers,              default: {}     # { question_index => answer_value }
      t.integer :nps_score                             # 0-10, extracted from NPS question

      t.timestamps
    end

    add_index :survey_responses, [:survey_id, :volunteer_profile_id], unique: true, name: "index_survey_responses_unique"
    add_index :survey_responses, :shift_id
    add_index :survey_responses, :nps_score

    add_foreign_key :survey_responses, :surveys
    add_foreign_key :survey_responses, :volunteer_profiles
    add_foreign_key :survey_responses, :shifts
  end
end

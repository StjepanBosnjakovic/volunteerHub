class CreateQuizAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_answers do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :quiz_question, null: false, foreign_key: true
      t.string :answer
      t.boolean :correct, default: false

      t.timestamps
    end

    add_index :quiz_answers, [ :volunteer_profile_id, :quiz_question_id ], unique: true, name: "index_quiz_answers_on_profile_and_question"
  end
end

class CreateQuizQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :question, null: false
      t.jsonb :options  # array of answer choices for multiple choice
      t.string :correct_answer, null: false
      t.integer :position, default: 0

      t.timestamps
    end
  end
end

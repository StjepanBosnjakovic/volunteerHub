class CreateQuizzes < ActiveRecord::Migration[8.1]
  def change
    create_table :quizzes do |t|
      t.references :onboarding_step, null: false, foreign_key: true
      t.integer :passing_score, default: 70

      t.timestamps
    end
  end
end

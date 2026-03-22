class CreateApplicationQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :application_questions do |t|
      t.references :opportunity, null: false, foreign_key: true
      t.string :question_type, null: false  # text, multiple_choice, file
      t.string :label, null: false
      t.jsonb :options
      t.integer :position, default: 0
      t.boolean :required, default: false

      t.timestamps
    end
  end
end

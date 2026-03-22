class CreateApplicationAnswers < ActiveRecord::Migration[8.1]
  def change
    create_table :application_answers do |t|
      t.references :volunteer_application, null: false, foreign_key: true
      t.references :application_question, null: false, foreign_key: true
      t.text :value

      t.timestamps
    end
  end
end

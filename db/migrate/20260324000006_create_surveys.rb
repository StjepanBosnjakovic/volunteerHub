class CreateSurveys < ActiveRecord::Migration[8.1]
  def change
    create_table :surveys do |t|
      t.bigint  :organisation_id, null: false
      t.string  :title,           null: false
      t.integer :trigger,         default: 0, null: false  # post_shift / post_program / pulse / manual
      t.jsonb   :questions,       default: []              # Array of question objects
      t.boolean :active,          default: true, null: false
      t.integer :grace_period_hours, default: 1           # Hours after shift end before sending

      t.timestamps
    end

    add_index :surveys, :organisation_id
    add_index :surveys, [:organisation_id, :trigger]
    add_index :surveys, :active

    add_foreign_key :surveys, :organisations
  end
end

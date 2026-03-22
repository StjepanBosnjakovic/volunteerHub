class CreateAvailabilities < ActiveRecord::Migration[8.1]
  def change
    create_table :availabilities do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.integer :day_of_week
      t.jsonb :time_blocks

      t.timestamps
    end
  end
end

class CreateBlackoutDates < ActiveRecord::Migration[8.1]
  def change
    create_table :blackout_dates do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.date :start_date
      t.date :end_date
      t.string :reason

      t.timestamps
    end
  end
end

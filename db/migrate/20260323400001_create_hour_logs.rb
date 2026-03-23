class CreateHourLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :hour_logs do |t|
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :program, null: false, foreign_key: true
      t.references :shift, null: true, foreign_key: true
      t.references :attendance, null: true, foreign_key: true
      t.date :date, null: false
      t.decimal :hours, precision: 6, scale: 2, null: false
      t.text :description
      t.integer :status, null: false, default: 0   # pending/approved/rejected
      t.integer :source, null: false, default: 1   # auto/self/bulk
      t.references :approved_by, null: true, foreign_key: { to_table: :users }
      t.datetime :approved_at
      t.string :rejection_reason
      t.boolean :disputed, null: false, default: false
      t.text :dispute_note
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end

    add_index :hour_logs, [:volunteer_profile_id, :date]
    add_index :hour_logs, [:program_id, :status]
    add_index :hour_logs, :attendance_id, unique: true
  end
end

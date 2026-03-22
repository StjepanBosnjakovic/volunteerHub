class CreateShiftAssignments < ActiveRecord::Migration[8.1]
  def change
    create_table :shift_assignments do |t|
      t.references :shift, null: false, foreign_key: true
      t.references :volunteer_profile, null: false, foreign_key: true
      t.references :shift_role, null: true, foreign_key: true
      t.integer :status, default: 0, null: false   # 0=confirmed, 1=waitlisted, 2=cancelled
      t.boolean :late_cancel, default: false, null: false
      t.datetime :cancelled_at

      t.timestamps
    end

    add_index :shift_assignments, [:shift_id, :volunteer_profile_id], unique: true
  end
end

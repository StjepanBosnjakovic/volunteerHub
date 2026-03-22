class CreateAttendances < ActiveRecord::Migration[8.1]
  def change
    create_table :attendances do |t|
      t.references :shift_assignment, null: false, foreign_key: true
      t.datetime :checked_in_at
      t.datetime :checked_out_at
      t.integer :method, default: 0, null: false   # 0=manual, 1=qr, 2=geo
      t.boolean :no_show, default: false, null: false
      t.boolean :late, default: false, null: false

      t.timestamps
    end

    add_index :attendances, :shift_assignment_id, unique: true
  end
end

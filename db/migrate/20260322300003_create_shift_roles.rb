class CreateShiftRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :shift_roles do |t|
      t.references :shift, null: false, foreign_key: true
      t.string :label, null: false
      t.integer :spots, null: false, default: 1

      t.timestamps
    end
  end
end

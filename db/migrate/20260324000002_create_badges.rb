class CreateBadges < ActiveRecord::Migration[8.1]
  def change
    create_table :badges do |t|
      t.bigint  :organisation_id          # nil = system-wide badge
      t.string  :name,          null: false
      t.text    :description
      t.string  :criteria_type, null: false  # hours_reached / milestone / consecutive_months / manual
      t.decimal :criteria_value, precision: 8, scale: 2

      t.timestamps
    end

    add_index :badges, :organisation_id
    add_index :badges, :criteria_type
  end
end

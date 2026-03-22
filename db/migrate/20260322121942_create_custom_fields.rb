class CreateCustomFields < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_fields do |t|
      t.references :organisation, null: false, foreign_key: true
      t.string :field_type
      t.string :label
      t.jsonb :options
      t.boolean :required
      t.integer :position

      t.timestamps
    end
  end
end

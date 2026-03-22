class CreateCustomFieldValues < ActiveRecord::Migration[8.1]
  def change
    create_table :custom_field_values do |t|
      t.references :custom_field, null: false, foreign_key: true
      t.text :value
      t.references :customizable, polymorphic: true, null: false

      t.timestamps
    end
  end
end

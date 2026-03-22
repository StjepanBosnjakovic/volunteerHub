class CreateInterestCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :interest_categories do |t|
      t.string :name
      t.references :organisation, null: false, foreign_key: true

      t.timestamps
    end
  end
end

class CreatePhase5Announcements < ActiveRecord::Migration[8.1]
  def change
    create_table :announcements do |t|
      t.bigint   :organisation_id, null: false
      t.bigint   :author_id,       null: false
      t.string   :title,           null: false
      t.integer  :status,          default: 0, null: false
      t.datetime :published_at
      t.datetime :scheduled_for

      t.timestamps

      t.index :organisation_id
      t.index :author_id
      t.index :status
      t.index :scheduled_for
    end

    add_foreign_key :announcements, :organisations
    add_foreign_key :announcements, :users, column: :author_id
  end
end

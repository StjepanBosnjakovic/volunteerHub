class CreatePhase5Notifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.bigint   :recipient_id,       null: false
      t.bigint   :organisation_id,    null: false
      t.string   :notification_type,  null: false
      t.datetime :read_at
      t.jsonb    :data,               default: {}
      t.string   :notifiable_type
      t.bigint   :notifiable_id

      t.timestamps

      t.index :recipient_id
      t.index :organisation_id
      t.index [:notifiable_type, :notifiable_id], name: "idx_notifications_notifiable"
      t.index [:recipient_id, :read_at],          name: "idx_notifications_recipient_read"
    end

    create_table :notification_preferences do |t|
      t.bigint  :user_id,           null: false
      t.string  :notification_type, null: false
      t.boolean :in_app,            default: true,  null: false
      t.boolean :email,             default: true,  null: false

      t.timestamps

      t.index [:user_id, :notification_type], unique: true, name: "idx_notification_prefs_unique"
    end

    add_foreign_key :notifications,             :users, column: :recipient_id
    add_foreign_key :notifications,             :organisations
    add_foreign_key :notification_preferences,  :users
  end
end

class CreatePhase5BroadcastMessages < ActiveRecord::Migration[8.1]
  def change
    create_table :broadcast_messages do |t|
      t.bigint  :organisation_id,  null: false
      t.bigint  :sender_id,        null: false
      t.string  :subject,          null: false
      t.text    :body,             null: false
      t.integer :channel,          default: 0, null: false
      t.jsonb   :segment_filters,  default: {}
      t.integer :status,           default: 0, null: false
      t.integer :recipient_count,  default: 0
      t.datetime :sent_at

      t.timestamps

      t.index :organisation_id
      t.index :sender_id
    end

    add_foreign_key :broadcast_messages, :organisations
    add_foreign_key :broadcast_messages, :users, column: :sender_id
  end
end

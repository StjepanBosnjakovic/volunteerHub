class CreatePhase5Messaging < ActiveRecord::Migration[8.1]
  def change
    create_table :conversations do |t|
      t.bigint  :organisation_id, null: false
      t.string  :title
      t.integer :conversation_type, default: 0, null: false

      t.timestamps

      t.index :organisation_id
    end

    create_table :conversation_participants do |t|
      t.bigint   :conversation_id, null: false
      t.bigint   :user_id,         null: false
      t.datetime :last_read_at

      t.timestamps

      t.index [:conversation_id, :user_id], unique: true, name: "idx_conversation_participants_unique"
    end

    create_table :messages do |t|
      t.bigint  :conversation_id, null: false
      t.bigint  :sender_id,       null: false
      t.integer :message_type,    default: 0, null: false

      t.timestamps

      t.index :conversation_id
      t.index :sender_id
    end

    create_table :message_reads do |t|
      t.bigint   :message_id, null: false
      t.bigint   :user_id,    null: false
      t.datetime :read_at,    null: false

      t.timestamps

      t.index [:message_id, :user_id], unique: true, name: "idx_message_reads_unique"
    end

    add_foreign_key :conversations,            :organisations
    add_foreign_key :conversation_participants, :conversations
    add_foreign_key :conversation_participants, :users
    add_foreign_key :messages,                 :conversations
    add_foreign_key :messages,                 :users, column: :sender_id
    add_foreign_key :message_reads,            :messages
    add_foreign_key :message_reads,            :users
  end
end

class CreatePhase5EmailTemplates < ActiveRecord::Migration[8.1]
  def change
    create_table :email_templates do |t|
      t.bigint  :organisation_id, null: false
      t.string  :event_type,      null: false
      t.string  :subject,         null: false
      t.text    :body_html,       null: false
      t.boolean :active,          default: true, null: false

      t.timestamps

      t.index [:organisation_id, :event_type], unique: true, name: "idx_email_templates_org_event"
    end

    create_table :email_campaigns do |t|
      t.bigint   :organisation_id,  null: false
      t.bigint   :sender_id,        null: false
      t.string   :name,             null: false
      t.string   :subject_a,        null: false
      t.string   :subject_b
      t.text     :body_html,        null: false
      t.jsonb    :segment_filters,  default: {}
      t.string   :channel,          default: "email", null: false
      t.integer  :status,           default: 0,       null: false
      t.integer  :recipient_count,  default: 0
      t.integer  :open_count_a,     default: 0
      t.integer  :open_count_b,     default: 0
      t.datetime :scheduled_at
      t.datetime :sent_at

      t.timestamps

      t.index :organisation_id
      t.index :sender_id
    end

    add_foreign_key :email_templates, :organisations
    add_foreign_key :email_campaigns, :organisations
    add_foreign_key :email_campaigns, :users, column: :sender_id
  end
end

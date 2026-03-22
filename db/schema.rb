# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_22_123234) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "availabilities", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "day_of_week"
    t.jsonb "time_blocks"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["volunteer_profile_id"], name: "index_availabilities_on_volunteer_profile_id"
  end

  create_table "blackout_dates", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "end_date"
    t.string "reason"
    t.date "start_date"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["volunteer_profile_id"], name: "index_blackout_dates_on_volunteer_profile_id"
  end

  create_table "coordinator_programs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.integer "programme_id"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_coordinator_programs_on_user_id"
  end

  create_table "credentials", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "credential_type"
    t.date "expires_at"
    t.string "name"
    t.text "notes"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["volunteer_profile_id"], name: "index_credentials_on_volunteer_profile_id"
  end

  create_table "custom_field_values", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "custom_field_id", null: false
    t.bigint "customizable_id", null: false
    t.string "customizable_type", null: false
    t.datetime "updated_at", null: false
    t.text "value"
    t.index ["custom_field_id"], name: "index_custom_field_values_on_custom_field_id"
    t.index ["customizable_type", "customizable_id"], name: "index_custom_field_values_on_customizable"
  end

  create_table "custom_fields", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "field_type"
    t.string "label"
    t.jsonb "options"
    t.bigint "organisation_id", null: false
    t.integer "position"
    t.boolean "required"
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_custom_fields_on_organisation_id"
  end

  create_table "emergency_contacts", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "name"
    t.string "phone"
    t.string "relationship"
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["volunteer_profile_id"], name: "index_emergency_contacts_on_volunteer_profile_id"
  end

  create_table "interest_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_interest_categories_on_organisation_id"
  end

  create_table "organisations", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_sender_address"
    t.string "email_sender_name"
    t.string "locale"
    t.string "name"
    t.string "primary_colour"
    t.string "slug"
    t.string "timezone"
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_organisations_on_slug", unique: true
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_skills_on_organisation_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.integer "failed_attempts"
    t.datetime "locked_at"
    t.bigint "organisation_id", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 3
    t.string "unconfirmed_email"
    t.string "unlock_token"
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["organisation_id"], name: "index_users_on_organisation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "volunteer_interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "interest_category_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["interest_category_id"], name: "index_volunteer_interests_on_interest_category_id"
    t.index ["volunteer_profile_id"], name: "index_volunteer_interests_on_volunteer_profile_id"
  end

  create_table "volunteer_profiles", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "first_name"
    t.boolean "is_minor"
    t.string "last_name"
    t.integer "max_hours_per_month"
    t.integer "max_hours_per_week"
    t.bigint "organisation_id", null: false
    t.string "phone"
    t.datetime "policy_accepted_at"
    t.string "preferred_name"
    t.string "pronouns"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["organisation_id"], name: "index_volunteer_profiles_on_organisation_id"
    t.index ["status"], name: "index_volunteer_profiles_on_status"
    t.index ["user_id"], name: "index_volunteer_profiles_on_user_id"
  end

  create_table "volunteer_skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "skill_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["skill_id"], name: "index_volunteer_skills_on_skill_id"
    t.index ["volunteer_profile_id"], name: "index_volunteer_skills_on_volunteer_profile_id"
  end

  add_foreign_key "availabilities", "volunteer_profiles"
  add_foreign_key "blackout_dates", "volunteer_profiles"
  add_foreign_key "coordinator_programs", "users"
  add_foreign_key "credentials", "volunteer_profiles"
  add_foreign_key "custom_field_values", "custom_fields"
  add_foreign_key "custom_fields", "organisations"
  add_foreign_key "emergency_contacts", "volunteer_profiles"
  add_foreign_key "interest_categories", "organisations"
  add_foreign_key "skills", "organisations"
  add_foreign_key "users", "organisations"
  add_foreign_key "volunteer_interests", "interest_categories"
  add_foreign_key "volunteer_interests", "volunteer_profiles"
  add_foreign_key "volunteer_profiles", "organisations"
  add_foreign_key "volunteer_profiles", "users"
  add_foreign_key "volunteer_skills", "skills"
  add_foreign_key "volunteer_skills", "volunteer_profiles"
end

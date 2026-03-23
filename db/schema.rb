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

ActiveRecord::Schema[8.1].define(version: 2026_03_22_300007) do
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end


  create_table "application_answers", force: :cascade do |t|
    t.bigint "volunteer_application_id", null: false
    t.bigint "application_question_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_application_id"], name: "index_application_answers_on_volunteer_application_id"
    t.index ["application_question_id"], name: "index_application_answers_on_application_question_id"
  end

  create_table "application_questions", force: :cascade do |t|
    t.bigint "opportunity_id", null: false
    t.string "question_type", null: false
    t.string "label", null: false
    t.jsonb "options"
    t.integer "position", default: 0
    t.boolean "required", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opportunity_id"], name: "index_application_questions_on_opportunity_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.bigint "shift_assignment_id", null: false
    t.datetime "checked_in_at"
    t.datetime "checked_out_at"
    t.integer "method", default: 0, null: false
    t.boolean "no_show", default: false, null: false
    t.boolean "late", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_assignment_id"], name: "index_attendances_on_shift_assignment_id", unique: true
  end

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

  create_table "onboarding_checklists", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "target_role"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_onboarding_checklists_on_organisation_id"
  end

  create_table "onboarding_steps", force: :cascade do |t|
    t.bigint "onboarding_checklist_id", null: false
    t.string "step_type", null: false
    t.string "title", null: false
    t.text "description"
    t.string "content_url"
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_checklist_id", "position"], name: "index_onboarding_steps_on_checklist_id_and_position"
  end

  create_table "opportunities", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "location"
    t.decimal "lat", precision: 10, scale: 7
    t.decimal "lng", precision: 10, scale: 7
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.integer "spots_available"
    t.string "commitment_level"
    t.integer "status", default: 0, null: false
    t.string "slug", null: false
    t.string "category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "status"], name: "index_opportunities_on_organisation_id_and_status"
    t.index ["slug"], name: "index_opportunities_on_slug", unique: true
    t.index ["starts_at"], name: "index_opportunities_on_starts_at"
    t.index ["status"], name: "index_opportunities_on_status"
  end

  create_table "opportunity_skills", force: :cascade do |t|
    t.bigint "opportunity_id", null: false
    t.bigint "skill_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["opportunity_id", "skill_id"], name: "index_opportunity_skills_on_opportunity_id_and_skill_id", unique: true
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

  create_table "programs", force: :cascade do |t|
    t.bigint "organisation_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id", "name"], name: "index_programs_on_organisation_id_and_name", unique: true
  end

  create_table "quiz_answers", force: :cascade do |t|
    t.bigint "volunteer_profile_id", null: false
    t.bigint "quiz_question_id", null: false
    t.string "answer"
    t.boolean "correct", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_profile_id", "quiz_question_id"], name: "index_quiz_answers_on_profile_and_question", unique: true
  end

  create_table "quiz_questions", force: :cascade do |t|
    t.bigint "quiz_id", null: false
    t.text "question", null: false
    t.jsonb "options"
    t.string "correct_answer", null: false
    t.integer "position", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["quiz_id"], name: "index_quiz_questions_on_quiz_id"
  end

  create_table "quizzes", force: :cascade do |t|
    t.bigint "onboarding_step_id", null: false
    t.integer "passing_score", default: 70
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["onboarding_step_id"], name: "index_quizzes_on_onboarding_step_id"
  end

  create_table "shift_assignments", force: :cascade do |t|
    t.bigint "shift_id", null: false
    t.bigint "volunteer_profile_id", null: false
    t.bigint "shift_role_id"
    t.integer "status", default: 0, null: false
    t.boolean "late_cancel", default: false, null: false
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_id", "volunteer_profile_id"], name: "index_shift_assignments_on_shift_and_volunteer", unique: true
  end

  create_table "shift_roles", force: :cascade do |t|
    t.bigint "shift_id", null: false
    t.string "label", null: false
    t.integer "spots", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["shift_id"], name: "index_shift_roles_on_shift_id"
  end

  create_table "shifts", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.bigint "coordinator_id"
    t.string "title", null: false
    t.string "location"
    t.decimal "lat", precision: 10, scale: 7
    t.decimal "lng", precision: 10, scale: 7
    t.datetime "starts_at", null: false
    t.datetime "ends_at", null: false
    t.integer "capacity"
    t.boolean "waitlist_enabled", default: false, null: false
    t.text "notes"
    t.string "recurrence_rule"
    t.string "qr_token"
    t.integer "cancellation_cutoff_hours", default: 24
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["program_id"], name: "index_shifts_on_program_id"
    t.index ["coordinator_id"], name: "index_shifts_on_coordinator_id"
    t.index ["qr_token"], name: "index_shifts_on_qr_token", unique: true
    t.index ["starts_at"], name: "index_shifts_on_starts_at"
  end

  create_table "skills", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.bigint "organisation_id", null: false
    t.datetime "updated_at", null: false
    t.index ["organisation_id"], name: "index_skills_on_organisation_id"
  end

  create_table "swap_requests", force: :cascade do |t|
    t.bigint "from_assignment_id", null: false
    t.bigint "to_assignment_id"
    t.bigint "requested_by_id", null: false
    t.bigint "reviewed_by_id"
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_assignment_id"], name: "index_swap_requests_on_from_assignment_id"
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

  create_table "volunteer_applications", force: :cascade do |t|
    t.bigint "volunteer_profile_id", null: false
    t.bigint "opportunity_id", null: false
    t.integer "status", default: 0, null: false
    t.integer "position"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_profile_id", "opportunity_id"], name: "index_volunteer_applications_unique", unique: true
    t.index ["status"], name: "index_volunteer_applications_on_status"
  end

  create_table "volunteer_interests", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "interest_category_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "volunteer_profile_id", null: false
    t.index ["interest_category_id"], name: "index_volunteer_interests_on_interest_category_id"
    t.index ["volunteer_profile_id"], name: "index_volunteer_interests_on_volunteer_profile_id"
  end

  create_table "volunteer_onboarding_progresses", force: :cascade do |t|
    t.bigint "volunteer_profile_id", null: false
    t.bigint "onboarding_step_id", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["volunteer_profile_id", "onboarding_step_id"], name: "index_vop_on_profile_and_step", unique: true
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
    t.index ["volunteer_profile_id"], name: "index_volunteer_profiles_on_volunteer_skill_id"
  end

  add_foreign_key "application_answers", "volunteer_applications"
  add_foreign_key "application_answers", "application_questions"
  add_foreign_key "application_questions", "opportunities"
  add_foreign_key "attendances", "shift_assignments"
  add_foreign_key "availabilities", "volunteer_profiles"
  add_foreign_key "blackout_dates", "volunteer_profiles"
  add_foreign_key "coordinator_programs", "users"
  add_foreign_key "credentials", "volunteer_profiles"
  add_foreign_key "custom_field_values", "custom_fields"
  add_foreign_key "custom_fields", "organisations"
  add_foreign_key "emergency_contacts", "volunteer_profiles"
  add_foreign_key "interest_categories", "organisations"
  add_foreign_key "onboarding_checklists", "organisations"
  add_foreign_key "onboarding_steps", "onboarding_checklists"
  add_foreign_key "opportunities", "organisations"
  add_foreign_key "opportunity_skills", "opportunities"
  add_foreign_key "opportunity_skills", "skills"
  add_foreign_key "programs", "organisations"
  add_foreign_key "quiz_answers", "volunteer_profiles"
  add_foreign_key "quiz_answers", "quiz_questions"
  add_foreign_key "quiz_questions", "quizzes"
  add_foreign_key "quizzes", "onboarding_steps"
  add_foreign_key "shift_assignments", "shifts"
  add_foreign_key "shift_assignments", "shift_roles"
  add_foreign_key "shift_assignments", "volunteer_profiles"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "shift_roles", "shifts"
  add_foreign_key "shifts", "programs"
  add_foreign_key "shifts", "users", column: "coordinator_id"
  add_foreign_key "skills", "organisations"
  add_foreign_key "swap_requests", "shift_assignments", column: "from_assignment_id"
  add_foreign_key "swap_requests", "shift_assignments", column: "to_assignment_id"
  add_foreign_key "swap_requests", "users", column: "requested_by_id"
  add_foreign_key "swap_requests", "users", column: "reviewed_by_id"
  add_foreign_key "users", "organisations"
  add_foreign_key "volunteer_applications", "opportunities"
  add_foreign_key "volunteer_applications", "volunteer_profiles"
  add_foreign_key "volunteer_interests", "interest_categories"
  add_foreign_key "volunteer_interests", "volunteer_profiles"
  add_foreign_key "volunteer_onboarding_progresses", "onboarding_steps"
  add_foreign_key "volunteer_onboarding_progresses", "volunteer_profiles"
  add_foreign_key "volunteer_profiles", "organisations"
  add_foreign_key "volunteer_profiles", "users"
  add_foreign_key "volunteer_skills", "skills"
  add_foreign_key "volunteer_skills", "volunteer_profiles"
end

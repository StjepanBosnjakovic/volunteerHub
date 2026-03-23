# VolunteerOS — Build Task List

Tech stack: **Ruby on Rails · Hotwire (Turbo + Stimulus) · PostgreSQL · Tailwind CSS**

Tasks are grouped by phase. Complete each phase before beginning the next. Items marked `[RAILS]`, `[TURBO]`, `[STIMULUS]` indicate the primary Rails/Hotwire mechanism involved.

---

## Phase 1 — Foundation ✅ COMPLETE

### 1.1 Project Setup
- [x] `rails new volunteer_os --database=postgresql --asset-pipeline=propshaft` (or esbuild)
- [x] Add gems: `devise`, `pundit`, `image_processing`, `active_storage`, `pagy`, `pg`, `sidekiq`, `redis`
- [x] Add JS: `@hotwired/turbo-rails`, `@hotwired/stimulus`, `tailwindcss-rails`
- [x] Configure Tailwind with a custom design system (colours, fonts, spacing)
- [x] Set up Sidekiq + Redis for background jobs
- [x] Set up Action Mailer with a transactional email provider (e.g. Postmark / SendGrid)
- [x] Configure Active Storage (local dev → S3/GCS in production)
- [x] Set up RSpec, FactoryBot, Shoulda Matchers, and Capybara for testing
- [x] Set up Brakeman (security), Rubocop, and a CI pipeline (GitHub Actions)

### 1.2 Multi-Tenancy — Organisation Model
- [x] Generate `Organisation` model: `name`, `slug`, `logo`, `primary_colour`, `timezone`, `locale`, `email_sender_name`, `email_sender_address`
- [x] Implement subdomain-based or path-based multi-tenancy (e.g. `acts_as_tenant` gem)
- [x] Seed default organisation for development
- [x] Organisation settings page [TURBO frames for section updates]

### 1.3 Authentication & Roles
- [x] Devise setup: email/password, confirmable, lockable, recoverable
- [x] `User` model with role enum: `super_admin`, `coordinator`, `read_only_staff`, `volunteer`
- [x] Pundit policies for each role (base policy + per-resource policies)
- [x] Program-scoped coordinator access (`CoordinatorProgram` join table)
- [x] Session management: remember me, session timeout
- [x] SSO stub (SAML/OIDC) — architecture placeholder for Phase 8

### 1.4 Volunteer Profiles
- [x] `VolunteerProfile` model: `first_name`, `last_name`, `preferred_name`, `pronouns`, `date_of_birth`, `phone`, `bio`, `status` (active/inactive/pending)
- [x] Avatar upload via Active Storage + image variants
- [x] Skills tagging: `Skill` model + `VolunteerSkill` join; autocomplete with Stimulus + Turbo
- [x] Interest categories: `InterestCategory` model with many-to-many
- [x] Availability grid: `Availability` model (day_of_week + time_block JSON column) [STIMULUS]
- [x] Blackout date ranges: `BlackoutDate` model
- [x] Max hours per week/month fields on profile
- [x] Emergency contacts: `EmergencyContact` model (nested form with Stimulus)
- [x] Custom org fields: `CustomField` model (field_type, label, options JSON); `CustomFieldValue` polymorphic
- [x] Minor safeguarding flag: auto-set when DOB < 18 years; gated content
- [x] Volunteer self-service: create / edit / deactivate own profile [TURBO]
- [x] Coordinator: edit any profile, archive leavers
- [x] Duplicate merge tool for coordinators
- [x] Bulk CSV/Excel import with field-mapping wizard [Stimulus multi-step form]
- [x] Export single profile as PDF (use `Prawn` or `WickedPdf`)
- [x] Export full roster as CSV (`csv` stdlib) / Excel (`caxlsx`)
- [x] GDPR erasure: anonymise PII, retain aggregate stats [background job]
- [x] Credential / document uploads: `Credential` model with expiry date; Active Storage attachment
- [x] Credential expiry alerts at 30/14/7 days [Sidekiq scheduled job]
- [x] E-signature for policy acceptance (inline checkbox + timestamp, or DocuSign stub)

---

## Phase 2 — Recruitment & Onboarding ✅ COMPLETE

### 2.1 Opportunity Listings
- [x] `Opportunity` model: `title`, `description`, `location`, `lat`, `lng`, `starts_at`, `ends_at`, `spots_available`, `commitment_level`, `status` (draft/published/closed)
- [x] `OpportunitySkill` join for required skills
- [x] Public listing index: filter by category, location, date, commitment level [TURBO frames]
- [x] Map view using Mapbox or Leaflet + Stimulus controller
- [x] SEO: meta tags, schema.org/VolunteerRole JSON-LD per listing page
- [x] Auto-generate shareable public URL (slug)
- [x] Embeddable iFrame widget endpoint (no-layout render)

### 2.2 Application Pipeline
- [x] `Application` model: `volunteer_id`, `opportunity_id`, `status` (applied/shortlisted/approved/declined/waitlisted), `position` (for ordering)
- [x] Short sign-up form for new volunteers; one-click for returning [TURBO]
- [x] Custom application questions: `ApplicationQuestion` (type: text/multiple_choice/file) + `ApplicationAnswer`
- [x] Kanban pipeline view [Stimulus drag-and-drop, Turbo streams for real-time updates]
- [x] Bulk approve/decline with templated messaging [Turbo stream + background mail job]
- [x] Waitlist: auto-promote next waitlisted applicant when a spot opens [callback + job]

### 2.3 Onboarding Workflows
- [x] `OnboardingChecklist` model per role/program
- [x] `OnboardingStep` model: `step_type` (video/document/quiz/upload/sign/induction), `title`, `content_url`, `position`
- [x] `VolunteerOnboardingProgress` join: `completed_at`, per step per volunteer
- [x] Progress bar UI [Turbo frame, updated on each step completion]
- [x] Quiz builder: `Quiz`, `QuizQuestion`, `QuizAnswer` models; inline grading
- [x] Automated stall reminders: if no progress for N days, send reminder email [Sidekiq job]
- [x] Coordinator dashboard: cohort completion rates [Turbo frame with live counts]

---

## Phase 3 — Scheduling & Shift Management

### 3.1 Programs
- [x] `Program` model: `name`, `description`, `organisation_id`, access-control to coordinators

### 3.2 Shift Creation
- [x] `Shift` model: `program_id`, `title`, `location`, `starts_at`, `ends_at`, `capacity`, `waitlist_enabled`, `coordinator_id`, `notes`, `recurrence_rule` (iCal RRULE string)
- [x] Single shift form
- [x] Recurring shift wizard: daily/weekly/custom RRULE (FREQ=DAILY/WEEKLY/MONTHLY + INTERVAL)
- [ ] Multi-day event wizard
- [x] `ShiftRole` model: role label + spots needed per shift
- [x] Clone shift / clone entire program schedule to a future date range
- [x] Capacity enforcement + optional waitlist at model layer

### 3.3 Volunteer Self-Scheduling
- [x] Calendar view (month/week/day) using Stimulus + custom lightweight JS calendar controller
- [x] List view with filters [TURBO frames]
- [x] Smart suggestions query: match volunteer skills, location proximity, stated availability
- [x] Sign-up / cancel shift [TURBO stream — update capacity counter live]
- [x] Cancellation cut-off enforcement; late-cancel flag on `ShiftAssignment`
- [x] Swap request: `SwapRequest` model; coordinator approval flow [Turbo stream notification]

### 3.4 Coordinator Scheduling Tools
- [ ] Drag-and-drop timeline/Gantt view [Stimulus + SortableJS]
- [x] Auto-fill suggestions: ranked volunteer list per open slot [background query]
- [x] One-click assign from suggestion list [TURBO]
- [ ] Conflict detection: query overlapping assignments and availability; show inline warning [Stimulus]
- [x] Bulk assign volunteers to recurring shift series
- [x] PDF schedule export (`Prawn`)
- [x] iCal feed endpoint per volunteer and per program

### 3.5 Check-In / Check-Out
- [x] `Attendance` model: `shift_assignment_id`, `checked_in_at`, `checked_out_at`, `method` (qr/manual/geo)
- [x] QR code generation per shift (unique `qr_token` on Shift, generated via `SecureRandom`)
- [x] QR scan endpoint: validate token, create/update Attendance record [TURBO stream]
- [x] Manual attendance toggle list [TURBO stream]
- [x] Geofenced auto-check-in stub (JS Geolocation API + Stimulus controller; compares coords to shift location)
- [x] Late/no-show detection job: runs after shift end, flags missing Attendance records, queues follow-up message

---

## Phase 4 — Hour Tracking & Verification ✅ COMPLETE

### 4.1 Hour Logging
- [x] `HourLog` model: `volunteer_id`, `program_id`, `shift_id` (nullable), `date`, `hours`, `description`, `status` (pending/approved/rejected), `source` (auto/self/bulk)
- [x] Auto-create HourLog from Attendance check-out
- [x] Volunteer self-log form [TURBO]
- [x] Coordinator bulk CSV upload → background import job

### 4.2 Approval Workflow
- [x] Coordinator pending queue [Turbo stream live updates]
- [x] One-click approve / reject / edit-and-approve [TURBO]
- [x] Auto-approve org setting (skip coordinator step)
- [x] Dispute flag: volunteer marks auto-logged hours as disputed; coordinator notified

### 4.3 Milestones & Dashboard
- [x] `Milestone` model: threshold hours + badge/message config
- [x] After-save callback on HourLog approval: check cumulative hours, trigger milestone [job]
- [x] Volunteer personal dashboard: cumulative hours by program + time period [Turbo frame]
- [x] Coordinator hour reports: by volunteer / program / date range / location
- [x] CSV / Excel export of hour data

---

## Phase 5 — Communications

### 5.1 In-App Messaging
- [ ] `Conversation` + `Message` models; `ConversationParticipant` join
- [ ] 1-to-1 and group conversations
- [ ] Real-time message delivery [Action Cable + Turbo Streams]
- [ ] Rich-text composer using Trix (built into Rails) with file attachments via Active Storage
- [ ] Read receipts: `MessageRead` model, updated on scroll/focus [Stimulus]
- [ ] Delivery receipts for email/SMS channels

### 5.2 Broadcast Messaging
- [ ] Segment builder: filter by role, program, shift, custom field values [Stimulus live preview]
- [ ] Broadcast job: iterate segment, queue individual messages / emails [Sidekiq batch]
- [ ] Channel selector: in-app / email / SMS / WhatsApp (feature-flagged)

### 5.3 Notifications
- [ ] `Notification` model: `recipient_id`, `type`, `read_at`, `data` (JSON)
- [ ] Notification bell with unread count [Turbo stream push on creation]
- [ ] Notification preferences per user (which triggers, which channels)
- [ ] Sidekiq scheduled jobs for: shift reminders (48h, 2h), credential expiry, inactivity nudge
- [ ] After-action jobs for: hour approval, milestone reached, onboarding stall

### 5.4 Email Templates & Branding
- [ ] `EmailTemplate` model: `event_type`, `subject`, `body_html`, `org_id`
- [ ] ActionMailer layout with org branding tokens
- [ ] Template preview in coordinator UI [TURBO frame iframe preview]
- [ ] Personalisation token interpolation service
- [ ] A/B subject line test: `EmailCampaign` model with variant A/B; track opens via pixel

### 5.5 Announcements & Newsletters
- [ ] `Announcement` model: `title`, `body` (rich text), `published_at`, `scheduled_for`
- [ ] Volunteer app feed showing latest announcements [Turbo stream]
- [ ] Newsletter builder: drag content blocks (Stimulus sortable); preview; schedule send

---

## Phase 6 — Recognition & Engagement

### 6.1 Badges
- [ ] `Badge` model: `name`, `description`, `artwork` (Active Storage), `criteria_type`, `criteria_value`, `org_id` (nil = system badge)
- [ ] `VolunteerBadge` join: `awarded_at`, `awarded_by_id`
- [ ] Badge award job: triggered by milestone, consecutive months, or manual coordinator action
- [ ] Badge display on volunteer profile
- [ ] Social share link: generate pre-filled LinkedIn share URL

### 6.2 Leaderboards
- [ ] Opt-in flag on VolunteerProfile
- [ ] Leaderboard query: scope by program / period / org; rank by hours / shifts / referrals
- [ ] Leaderboard page with Turbo frame refresh [cached fragment, refreshed on schedule]

### 6.3 References & Testimonials
- [ ] `Reference` model: `volunteer_id`, `coordinator_id`, `stats_snapshot` (JSON), `pdf_attachment`
- [ ] PDF generation using Prawn with verified stats
- [ ] Volunteer reference request flow [TURBO]
- [ ] `Testimonial` model: `quote`, `published` (boolean, requires volunteer consent)

### 6.4 Surveys
- [ ] `Survey` model: `title`, `trigger` (post_shift/post_program/pulse), `questions` (JSON schema)
- [ ] `SurveyResponse` model: `volunteer_id`, `survey_id`, `shift_id`, `answers` (JSON)
- [ ] Auto-send post-shift survey job (runs after shift end + grace period)
- [ ] NPS score calculation + open text aggregation
- [ ] Feedback dashboard: trend charts using `chartkick` + `groupdate` [Turbo frame]

---

## Phase 7 — Reporting & Analytics

### 7.1 Standard Reports
- [ ] Volunteer Summary report (status breakdown, growth chart)
- [ ] Hours by Program report
- [ ] Retention & Churn report (cohort analysis)
- [ ] Shift Fill Rate report
- [ ] Onboarding Funnel report
- [ ] Credential Compliance report
- [ ] Impact Statement report (hours × government labour rate)
- [ ] Communication Stats report (open/click/opt-out rates)
- [ ] All reports: date-range filter, CSV/Excel/PDF export

### 7.2 Custom Report Builder
- [ ] `SavedReport` model: `name`, `dimensions`, `metrics`, `filters` (JSON), `org_id`
- [ ] Builder UI: drag-and-drop dimension/metric chips [Stimulus]
- [ ] Query engine: build ActiveRecord query from JSON config
- [ ] Share saved report with other coordinators
- [ ] Scheduled report delivery: `ReportSchedule` model; Sidekiq cron job generates and emails PDF/CSV

### 7.3 Executive Dashboard
- [ ] KPI card components (volunteers, hours this month, active programs, fill rate)
- [ ] Trend sparklines using Chartkick
- [ ] Shareable read-only token: `DashboardToken` model; public route with no auth check [TURBO]

---

## Phase 8 — Organisation Administration & Integrations

### 8.1 Organisation Settings UI
- [ ] Branding settings (logo upload, colour picker) [Stimulus live preview]
- [ ] Timezone/locale settings
- [ ] Default notification preferences
- [ ] ToS / privacy policy document upload
- [ ] Data retention policy: configurable archive/delete rules

### 8.2 Multi-Site / Multi-Team
- [ ] `Site` model: `organisation_id`, `name`, `address`
- [ ] Associate volunteers, shifts, and coordinators with sites
- [ ] Site-scoped coordinator access
- [ ] Cross-site reporting for Super Admins

### 8.3 Custom Roles
- [ ] `Role` model with permissions bitmask or JSON array
- [ ] Role clone + permission editor UI
- [ ] Pundit integration: resolve permissions from custom role at runtime

### 8.4 Audit Log
- [ ] Use `paper_trail` gem on all key models
- [ ] Audit log viewer for Super Admins (filterable by user, model, date)

### 8.5 Public REST API
- [ ] Namespace: `/api/v1/`
- [ ] OAuth 2.0 via `doorkeeper` gem
- [ ] Endpoints: volunteers, shifts, hours, programs, messages, reports
- [ ] JSON serialisation with `blueprinter` or `jsonapi-serializer`
- [ ] Webhook delivery: `Webhook` model + `WebhookDelivery`; retry with exponential backoff [Sidekiq]
- [ ] Rate limiting: `rack-attack` gem (1,000/h standard, 10,000/h enterprise)
- [ ] OpenAPI spec + Swagger UI mounted at `/api/docs`

### 8.6 Native Integrations
- [ ] **Google/Outlook Calendar**: iCal feed (Phase 3) + Google Calendar API two-way sync [background job]
- [ ] **Stripe**: `stripe-ruby` gem; payment intent for registration fees; webhook handler
- [ ] **Twilio SMS**: ActionMailer SMS adapter or direct Twilio REST calls
- [ ] **Zapier/Make**: expose REST API (Phase 8.5) + document triggers/actions
- [ ] **Slack**: incoming webhook for shift reminders; Slack OAuth for DM alerts
- [ ] **Salesforce**: REST API sync job (volunteer ↔ contact, activity logging)
- [ ] **Mailchimp**: sync volunteer segments via Mailchimp API v3
- [ ] **Xero**: export hour valuations as invoices/bills via Xero API
- [ ] SSO: `omniauth-saml` + `omniauth-openid-connect` (Enterprise)

---

## Phase 9 — Mobile, PWA & Polish

### 9.1 Progressive Web App
- [ ] Service worker via `serviceworker-rails` or Vite PWA plugin
- [ ] Cache shift schedule and volunteer profile for offline access
- [ ] Background sync: queue check-in events offline, flush on reconnect
- [ ] Web app manifest: icons, theme colour, `display: standalone`
- [ ] Push notifications via Web Push API + `webpush` gem

### 9.2 Dark Mode
- [ ] Tailwind `dark:` class variants throughout
- [ ] Stimulus controller to toggle `dark` class on `<html>`; persist to localStorage + user preference

### 9.3 Accessibility (WCAG 2.1 AA)
- [ ] Audit all pages with axe-core / Lighthouse
- [ ] Keyboard navigation for all interactive elements
- [ ] ARIA labels on icons, modals, and dynamic Turbo regions
- [ ] Focus management after Turbo navigations [Stimulus]
- [ ] Colour contrast check against Tailwind theme
- [ ] Screen reader testing (VoiceOver / NVDA)

### 9.4 Performance
- [ ] Fragment caching for public pages (opportunity listings, leaderboards)
- [ ] Russian-doll caching for coordinator dashboards
- [ ] Database: add indexes identified by `rails db:explain` / `pg_stat_statements`
- [ ] N+1 query audit with `bullet` gem
- [ ] Image lazy-loading + responsive srcsets via Active Storage variants
- [ ] Turbo prefetch for nav links
- [ ] Rack::Deflater + asset fingerprinting / CDN

### 9.5 Ops & Reliability
- [ ] Dockerfile + docker-compose for local dev
- [ ] Production deploy config (Kamal or Render/Heroku)
- [ ] Environment variable management (Rails credentials / dotenv)
- [ ] Automated DB backup script (pg_dump → S3)
- [ ] Health check endpoint `/up` (Rails default)
- [ ] Error monitoring: Sentry or AppSignal integration
- [ ] Uptime/status page (BetterUptime or self-hosted)
- [ ] Load testing baseline with k6 or Locust

---

## Ongoing / Cross-Cutting

- [ ] Write model specs for every model (validations, scopes, callbacks)
- [ ] Write system specs for every critical user journey (Capybara)
- [ ] Maintain OpenAPI spec in sync with API changes
- [ ] Keep `TASKS.md` up to date as items are completed or scope changes

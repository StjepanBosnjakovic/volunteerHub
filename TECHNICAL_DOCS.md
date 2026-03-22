# VolunteerOS — Technical Documentation

Architecture, data models, API reference, and development guide for engineers working on VolunteerOS.

---

## Table of Contents

- [Architecture Overview](#architecture-overview)
- [Technology Stack](#technology-stack)
- [Local Development Setup](#local-development-setup)
- [Environment Variables](#environment-variables)
- [Database Schema](#database-schema)
  - [Core Models](#core-models)
  - [Entity Relationship Summary](#entity-relationship-summary)
- [Authentication & Authorisation](#authentication--authorisation)
- [Multi-Tenancy](#multi-tenancy)
- [Background Jobs](#background-jobs)
- [Real-Time Features (Hotwire)](#real-time-features-hotwire)
- [File Storage](#file-storage)
- [Email](#email)
- [REST API](#rest-api)
- [Webhooks](#webhooks)
- [Testing](#testing)
- [CI/CD Pipeline](#cicd-pipeline)
- [Deployment](#deployment)
- [Security Practices](#security-practices)
- [Performance Guidelines](#performance-guidelines)
- [Adding a New Feature](#adding-a-new-feature)

---

## Architecture Overview

VolunteerOS is a monolithic Ruby on Rails application using a **Majestic Monolith** pattern. Real-time UI updates are delivered via Hotwire (Turbo Streams + Turbo Frames) over Action Cable, avoiding the complexity of a separate front-end SPA. Background processing runs through Sidekiq workers backed by Redis.

```
Browser / Mobile (PWA)
        │
        ▼
    Nginx / CDN
        │
        ▼
   Rails App (Puma)
  ┌─────────────────────────────────────────┐
  │  Turbo Frames  │  Turbo Streams (WS)    │
  │  Controllers   │  Action Cable          │
  │  Pundit        │  ActiveRecord          │
  └─────────────────────────────────────────┘
        │                    │
        ▼                    ▼
   PostgreSQL             Redis
                            │
                            ▼
                         Sidekiq
                   (background workers)
                            │
                 ┌──────────┴──────────┐
                 ▼                     ▼
          Action Mailer          External APIs
       (email / SMS / push)   (Stripe, Twilio, etc.)
```

---

## Technology Stack

| Layer | Technology | Version |
|-------|-----------|---------|
| Language | Ruby | 3.3+ |
| Framework | Ruby on Rails | 7.2+ |
| Database | PostgreSQL | 16+ |
| Cache / Queue | Redis | 7+ |
| Background jobs | Sidekiq | 7+ |
| Front-end reactivity | Hotwire (Turbo + Stimulus) | Turbo 8 |
| CSS framework | Tailwind CSS | 3+ |
| Asset pipeline | Propshaft + esbuild | — |
| Authentication | Devise | 4.9+ |
| Authorisation | Pundit | 2.3+ |
| Multi-tenancy | acts_as_tenant | 0.6+ |
| File storage | Active Storage (S3/GCS) | — |
| Image processing | image_processing (libvips) | — |
| Pagination | Pagy | 8+ |
| Testing | RSpec + FactoryBot + Capybara | — |
| Security scan | Brakeman | — |
| Linting | RuboCop + rubocop-rails | — |

---

## Local Development Setup

### Prerequisites

- Ruby 3.3+ (use `rbenv` or `asdf`)
- PostgreSQL 16+
- Redis 7+
- Node.js 20+ and Yarn 1.22+
- `libvips` (image processing)

### Setup Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-org/volunteeros.git
cd volunteeros

# 2. Install Ruby dependencies
bundle install

# 3. Install JavaScript dependencies
yarn install

# 4. Configure environment variables
cp .env.example .env
# Edit .env with your local credentials

# 5. Create and seed the database
bin/rails db:create db:migrate db:seed

# 6. Start all processes (Rails + Sidekiq + CSS watcher)
bin/dev
```

`bin/dev` uses `Procfile.dev` to start all required processes via `foreman` or `overmind`.

### Docker (alternative)

```bash
docker compose up
```

The provided `docker-compose.yml` starts Rails, PostgreSQL, and Redis together.

---

## Environment Variables

All secrets are stored in environment variables (never committed to source control). A `.env.example` file documents every required key.

| Variable | Description |
|----------|-------------|
| `DATABASE_URL` | PostgreSQL connection string |
| `REDIS_URL` | Redis connection string |
| `SECRET_KEY_BASE` | Rails secret key (generate with `rails secret`) |
| `DEVISE_SECRET` | Devise pepper (generate with `rails secret`) |
| `AWS_ACCESS_KEY_ID` | AWS key for Active Storage (production) |
| `AWS_SECRET_ACCESS_KEY` | AWS secret for Active Storage (production) |
| `AWS_BUCKET` | S3 bucket name |
| `SMTP_HOST` | Outbound email SMTP host |
| `SMTP_PORT` | Outbound email SMTP port |
| `SMTP_USERNAME` | SMTP credentials |
| `SMTP_PASSWORD` | SMTP credentials |
| `TWILIO_ACCOUNT_SID` | Twilio SMS |
| `TWILIO_AUTH_TOKEN` | Twilio SMS |
| `TWILIO_FROM_NUMBER` | Twilio sender number |
| `STRIPE_PUBLISHABLE_KEY` | Stripe integration |
| `STRIPE_SECRET_KEY` | Stripe integration |
| `STRIPE_WEBHOOK_SECRET` | Stripe webhook signature verification |
| `SENTRY_DSN` | Error monitoring |

In production, use Rails encrypted credentials (`bin/rails credentials:edit`) or a secrets manager (AWS Secrets Manager, GCP Secret Manager).

---

## Database Schema

### Core Models

#### `organisations`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `name` | string | required |
| `slug` | string | unique, used in subdomain/path |
| `logo` | string | Active Storage attachment key |
| `primary_colour` | string | hex colour |
| `timezone` | string | IANA timezone string |
| `locale` | string | e.g. `en-AU` |
| `email_sender_name` | string | |
| `email_sender_address` | string | |
| `created_at` / `updated_at` | datetime | |

#### `users`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `organisation_id` | bigint FK | `organisations` |
| `email` | string | unique per org |
| `encrypted_password` | string | Devise |
| `role` | integer | enum: `super_admin(0)`, `coordinator(1)`, `read_only_staff(2)`, `volunteer(3)` |
| `confirmed_at` | datetime | Devise confirmable |
| `locked_at` | datetime | Devise lockable |
| `remember_created_at` | datetime | Devise |
| `sign_in_count` | integer | |
| `current_sign_in_at` | datetime | |

#### `volunteer_profiles`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `user_id` | bigint FK | `users` |
| `organisation_id` | bigint FK | `organisations` |
| `first_name` | string | |
| `last_name` | string | |
| `preferred_name` | string | |
| `pronouns` | string | |
| `date_of_birth` | date | |
| `phone` | string | |
| `bio` | text | |
| `status` | integer | enum: `pending(0)`, `active(1)`, `inactive(2)` |
| `is_minor` | boolean | auto-set by before_save callback |
| `max_hours_per_week` | integer | |
| `max_hours_per_month` | integer | |
| `availability` | jsonb | `{ "mon": ["morning","afternoon"], ... }` |

#### `opportunities`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `organisation_id` | bigint FK | |
| `title` | string | |
| `description` | text | |
| `location` | string | |
| `lat` | decimal | |
| `lng` | decimal | |
| `starts_at` | datetime | |
| `ends_at` | datetime | |
| `spots_available` | integer | |
| `commitment_level` | string | e.g. `one_off`, `ongoing` |
| `status` | integer | enum: `draft(0)`, `published(1)`, `closed(2)` |
| `slug` | string | unique, URL-friendly |

#### `applications`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `volunteer_profile_id` | bigint FK | |
| `opportunity_id` | bigint FK | |
| `status` | integer | enum: `applied(0)`, `shortlisted(1)`, `approved(2)`, `declined(3)`, `waitlisted(4)` |
| `position` | integer | for Kanban ordering |

#### `shifts`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `program_id` | bigint FK | |
| `title` | string | |
| `location` | string | |
| `starts_at` | datetime | |
| `ends_at` | datetime | |
| `capacity` | integer | |
| `waitlist_enabled` | boolean | |
| `coordinator_id` | bigint FK | `users` |
| `recurrence_rule` | string | iCal RRULE string (nullable) |
| `notes` | text | |

#### `shift_assignments`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `shift_id` | bigint FK | |
| `volunteer_profile_id` | bigint FK | |
| `status` | integer | enum: `confirmed(0)`, `waitlisted(1)`, `cancelled(2)` |
| `late_cancel` | boolean | |

#### `attendances`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `shift_assignment_id` | bigint FK | |
| `checked_in_at` | datetime | |
| `checked_out_at` | datetime | |
| `method` | integer | enum: `qr(0)`, `manual(1)`, `geo(2)` |

#### `hour_logs`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `volunteer_profile_id` | bigint FK | |
| `program_id` | bigint FK | |
| `shift_id` | bigint FK | nullable |
| `date` | date | |
| `hours` | decimal | |
| `description` | text | |
| `status` | integer | enum: `pending(0)`, `approved(1)`, `rejected(2)` |
| `source` | integer | enum: `auto(0)`, `self(1)`, `bulk(2)` |

#### `notifications`
| Column | Type | Notes |
|--------|------|-------|
| `id` | bigint PK | |
| `recipient_id` | bigint FK | `users` |
| `type` | string | STI type string |
| `read_at` | datetime | nullable |
| `data` | jsonb | event-specific payload |

### Entity Relationship Summary

```
Organisation ──< User
Organisation ──< VolunteerProfile
Organisation ──< Opportunity ──< Application >── VolunteerProfile
Organisation ──< Program ──< Shift ──< ShiftAssignment >── VolunteerProfile
                                  ShiftAssignment ──< Attendance
Program ──< OnboardingChecklist ──< OnboardingStep
VolunteerProfile ──< HourLog
VolunteerProfile ──< Credential
VolunteerProfile ──< VolunteerBadge >── Badge
User ──< Notification
```

---

## Authentication & Authorisation

### Authentication (Devise)

Devise is configured with the following modules: `database_authenticatable`, `registerable`, `recoverable`, `rememberable`, `trackable`, `validatable`, `confirmable`, `lockable`.

Configuration lives in `config/initializers/devise.rb`. Key settings:

```ruby
config.timeout_in = 2.hours
config.lock_strategy = :failed_attempts
config.maximum_attempts = 5
config.unlock_strategy = :time
config.unlock_in = 30.minutes
```

### Authorisation (Pundit)

Every controller action is authorised via Pundit policies in `app/policies/`. The base policy pattern:

```ruby
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?   = user.coordinator? || user.super_admin?
  def show?    = scope.exists?(id: record.id)
  def create?  = user.coordinator? || user.super_admin?
  def update?  = user.coordinator? || user.super_admin?
  def destroy? = user.super_admin?
end
```

Controllers call `authorize @record` before any action. Scope queries use `policy_scope(Model)` to automatically filter records by the current user's role and organisation.

---

## Multi-Tenancy

Tenancy is implemented with the `acts_as_tenant` gem scoped to `Organisation`. Every tenanted model includes:

```ruby
acts_as_tenant :organisation
```

The current tenant is set in `ApplicationController`:

```ruby
before_action :set_tenant

def set_tenant
  set_current_tenant(current_organisation)
end
```

`current_organisation` resolves from the subdomain (`request.subdomain`) or a path parameter, depending on deployment configuration.

> **Important:** Never query tenanted models without an active tenant set — `acts_as_tenant` will raise `ActiveRecord::RecordNotFound` rather than leaking cross-tenant data.

---

## Background Jobs

All background work runs through Sidekiq. Job classes live in `app/jobs/`.

### Scheduled Jobs (Sidekiq-Cron)

Configured in `config/sidekiq.yml`:

| Job | Schedule | Description |
|-----|----------|-------------|
| `CredentialExpiryAlertJob` | Daily 08:00 | Send alerts for credentials expiring in 30/14/7 days |
| `OnboardingStallReminderJob` | Daily 09:00 | Remind volunteers stalled in onboarding |
| `ShiftReminderJob` | Every hour | Send 48h and 2h shift reminders |
| `NoShowDetectionJob` | Every 15 min | Flag missing attendance after shift end |
| `InactivityNudgeJob` | Weekly | Email volunteers inactive for X days |
| `ReportScheduleJob` | Daily 06:00 | Generate and email scheduled reports |

### Writing a New Job

```ruby
class MyNewJob < ApplicationJob
  queue_as :default
  sidekiq_options retry: 3

  def perform(record_id)
    record = MyModel.find(record_id)
    # ... work ...
  end
end

# Enqueue
MyNewJob.perform_later(record.id)
# Schedule
MyNewJob.set(wait: 1.hour).perform_later(record.id)
```

Always pass IDs, not ActiveRecord objects, to avoid serialisation issues.

---

## Real-Time Features (Hotwire)

### Turbo Frames

Used for in-place partial page updates without full navigation. Controllers respond to Turbo Frame requests by rendering only the targeted `<turbo-frame>` partial.

```erb
<%# In the view %>
<turbo-frame id="applications_list">
  <%= render @applications %>
</turbo-frame>

<%# In the controller — no special code needed; Turbo handles it %>
```

### Turbo Streams

Used for broadcasting updates to multiple connected clients via Action Cable.

```ruby
# In a model callback or job
Turbo::StreamsChannel.broadcast_replace_to(
  "org_#{organisation_id}_applications",
  target: "application_#{application.id}",
  partial: "applications/application",
  locals: { application: application }
)
```

```erb
<%# Subscribe in the view %>
<%= turbo_stream_from "org_#{current_organisation.id}_applications" %>
```

### Stimulus Controllers

JavaScript behaviour is encapsulated in Stimulus controllers in `app/javascript/controllers/`. Follow the naming convention: a controller for `data-controller="availability-grid"` lives at `availability_grid_controller.js`.

---

## File Storage

Active Storage is used for all file attachments. Configuration:

- **Development:** `config/storage.yml` → `local` disk service
- **Production:** `config/storage.yml` → `amazon` (S3) or `google` (GCS) service

Direct uploads to S3 are used for large files (avatars, credential documents) to avoid routing file bytes through the Rails process.

Image variants are generated lazily using `libvips`:

```ruby
class VolunteerProfile < ApplicationRecord
  has_one_attached :avatar

  def avatar_thumbnail
    avatar.variant(resize_to_fill: [100, 100]).processed
  end
end
```

---

## Email

Action Mailer with the SMTP adapter is used for transactional email. Mailer classes live in `app/mailers/`. All emails use a base layout at `app/views/layouts/mailer.html.erb` that injects organisation branding (logo, primary colour).

Personalisation tokens (e.g. `{{first_name}}`) are interpolated by `EmailTemplateInterpolationService` before the mailer renders the template body.

All email sends are performed in background jobs (never inline in a web request):

```ruby
VolunteerMailer.shift_reminder(shift_assignment).deliver_later
```

---

## REST API

The public API is namespaced under `/api/v1/`. Authentication uses OAuth 2.0 Bearer tokens issued by Doorkeeper.

### Authentication

```
POST /oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=...&client_secret=...
```

Include the token in subsequent requests:

```
Authorization: Bearer <token>
```

### Key Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/api/v1/volunteers` | List volunteers (paginated) |
| GET | `/api/v1/volunteers/:id` | Retrieve a volunteer |
| POST | `/api/v1/volunteers` | Create a volunteer |
| PATCH | `/api/v1/volunteers/:id` | Update a volunteer |
| GET | `/api/v1/shifts` | List shifts |
| POST | `/api/v1/shifts` | Create a shift |
| GET | `/api/v1/hour_logs` | List hour logs |
| POST | `/api/v1/hour_logs` | Create an hour log |
| GET | `/api/v1/programs` | List programs |

Responses follow the JSON:API specification. Pagination uses `pagy` with `Link` headers.

Rate limits:
- Standard: 1,000 requests/hour
- Enterprise: 10,000 requests/hour

Rate limit headers are included in every response:

```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 994
X-RateLimit-Reset: 1711000000
```

Interactive API documentation (Swagger UI) is mounted at `/api/docs`.

---

## Webhooks

Organisations can register webhook endpoints via **Settings → API → Webhooks**.

Webhook deliveries are handled by `WebhookDeliveryJob` with exponential backoff retries (up to 5 attempts over 24 hours).

**Supported events:**

| Event | Payload |
|-------|---------|
| `volunteer.created` | volunteer profile object |
| `volunteer.updated` | before/after profile objects |
| `shift.booked` | shift assignment object |
| `shift.cancelled` | shift assignment object |
| `hour_log.approved` | hour log object |
| `application.status_changed` | application with old/new status |

**Signature verification:** Each delivery includes an `X-VolunteerOS-Signature` header (HMAC-SHA256 of the raw body using your webhook secret). Always verify this before processing.

```ruby
expected = OpenSSL::HMAC.hexdigest("SHA256", webhook_secret, request.raw_post)
ActiveSupport::SecurityUtils.secure_compare(expected, request.headers["X-VolunteerOS-Signature"])
```

---

## Testing

The test suite uses RSpec with the following helpers:

- **FactoryBot** — test data factories in `spec/factories/`
- **Shoulda Matchers** — one-liner model tests
- **Capybara + Cuprite** — system/integration tests against a headless Chromium browser

### Running Tests

```bash
# All tests
bundle exec rspec

# Single file
bundle exec rspec spec/models/volunteer_profile_spec.rb

# System tests only
bundle exec rspec spec/system/

# With coverage report
COVERAGE=true bundle exec rspec
```

### Test Types

| Type | Location | Purpose |
|------|----------|---------|
| Model specs | `spec/models/` | Validations, scopes, callbacks, associations |
| Request specs | `spec/requests/` | Controller/routing layer; no browser |
| Policy specs | `spec/policies/` | Pundit policy rules |
| Job specs | `spec/jobs/` | Background job logic |
| System specs | `spec/system/` | Full end-to-end user journeys via browser |
| Mailer specs | `spec/mailers/` | Email content and delivery |

### Coverage

We target ≥ 90% line coverage. SimpleCov reports are generated in `coverage/index.html`.

---

## CI/CD Pipeline

The GitHub Actions pipeline (`.github/workflows/ci.yml`) runs on every pull request and push to `main`:

1. **lint** — RuboCop + Brakeman security scan
2. **test** — RSpec suite with PostgreSQL and Redis services
3. **build** — Docker image build check

Merging to `main` triggers the **deploy** workflow which pushes to production via Kamal.

---

## Deployment

### Production (Kamal)

```bash
# Initial deploy
bin/kamal setup

# Subsequent deploys
bin/kamal deploy
```

`config/deploy.yml` defines the server list, Docker image registry, and environment variable sources.

### Environment

| Service | Recommendation |
|---------|---------------|
| App servers | 2–4 Puma workers, 5 threads each |
| Sidekiq | 1–2 processes, 10 concurrency each |
| PostgreSQL | Managed (RDS, Cloud SQL) with read replica for reports |
| Redis | Managed (ElastiCache, Cloud Memorystore) with persistence enabled |
| File storage | S3 or GCS with versioning enabled |
| CDN | CloudFront or Cloudflare in front of static assets |

### Health Check

Rails provides a built-in health endpoint at `GET /up` that returns `200 OK` when the app and database are reachable.

---

## Security Practices

- All database queries go through ActiveRecord; raw SQL is avoided to prevent injection.
- Brakeman runs in CI and blocks merges on new high-severity findings.
- User-supplied HTML is always sanitised with `ActionView::Helpers::SanitizeHelper` or stored as Trix rich text (which sanitises on render).
- File uploads are validated for MIME type and size before storage. Uploaded files are never executed.
- Sensitive columns (e.g. emergency contact phone numbers) are encrypted at rest using `attr_encrypted` where required by compliance.
- All cookies use `HttpOnly`, `Secure`, and `SameSite=Lax` flags.
- Content Security Policy headers are configured in `config/initializers/content_security_policy.rb`.
- `rack-attack` throttles abusive clients by IP before requests reach Rails.
- Paper Trail records every change to key models with user ID and timestamp.

---

## Performance Guidelines

- **N+1 queries:** Use `includes` or `preload` for associations rendered in views. The `bullet` gem detects N+1s in development.
- **Fragment caching:** Public pages (opportunity listings, leaderboards) use fragment caching keyed on the record's `cache_key_with_version`.
- **Database indexes:** Add an index for every foreign key and every column used in a `WHERE` or `ORDER BY` clause. Run `rails db:explain` to detect sequential scans.
- **Pagination:** Always paginate collection queries using `pagy`. Never load unbounded result sets.
- **Background work:** Any operation that may take more than ~100ms (bulk emails, CSV imports, report generation) must be performed in a Sidekiq job.
- **Turbo prefetch:** Nav links use `data-turbo-prefetch` to load pages speculatively on hover.

---

## Adding a New Feature

1. **Branch** from `main` using the naming convention `feature/<short-description>`.
2. **Generate** necessary migrations, models, and controllers with Rails generators.
3. **Add Pundit policy** for any new model that users can access.
4. **Scope to tenant** with `acts_as_tenant :organisation` on new models.
5. **Write specs:** model spec (validations/scopes), request spec (auth/authorisation), and at least one system spec for the critical user journey.
6. **Run the full suite** locally before opening a PR.
7. **Open a PR** — CI must pass. At least one reviewer approval required before merge.
8. **Update `TASKS.md`** to mark the corresponding task as complete.
9. **Update API docs** if the change adds or modifies API endpoints.

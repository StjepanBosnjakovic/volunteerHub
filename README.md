# VolunteerOS

A modern, mobile-first platform for managing volunteers across their full lifecycle — from recruitment to recognition.

**Tech stack:** Ruby on Rails · Hotwire (Turbo + Stimulus) · PostgreSQL · Tailwind CSS

---

## Table of Contents

- [Overview](#overview)
- [Target Users](#target-users)
- [Feature Areas](#feature-areas)
  - [1. Volunteer Profiles](#1-volunteer-profiles)
  - [2. Recruitment & Onboarding](#2-recruitment--onboarding)
  - [3. Scheduling & Shift Management](#3-scheduling--shift-management)
  - [4. Hour Tracking & Verification](#4-hour-tracking--verification)
  - [5. Communications](#5-communications)
  - [6. Recognition & Engagement](#6-recognition--engagement)
  - [7. Reporting & Analytics](#7-reporting--analytics)
  - [8. Organisation Administration](#8-organisation-administration)
  - [9. Integrations & API](#9-integrations--api)
  - [10. Mobile App](#10-mobile-app)
- [Non-Functional Requirements](#non-functional-requirements)
- [Phased Delivery Plan](#phased-delivery-plan)
- [Development Task List](#development-task-list)

---

## Overview

VolunteerOS replaces fragmented spreadsheets, email chains, and disconnected tools with a single system that covers the full volunteer lifecycle. It targets nonprofits, community organisations, event agencies, and social enterprises of all sizes — from a 10-person neighbourhood group to a national charity coordinating thousands of volunteers simultaneously.

**Supported platforms:** Web app, iOS, Android, Progressive Web App (offline-capable).

---

## Target Users

| Role | Description |
|------|-------------|
| Volunteer Coordinators | Organisation staff who recruit, schedule, and manage volunteers day-to-day |
| Volunteers | Individuals who sign up, log hours, and communicate with coordinators |
| Program Managers | Senior staff who oversee multiple programs and review impact reports |
| Organisation Admins | IT/ops staff who configure integrations, roles, and billing |
| External Stakeholders | Donors or board members who view curated impact dashboards |

---

## Feature Areas

### 1. Volunteer Profiles

Every volunteer has a structured profile that acts as a single source of truth across all modules.

**Profile fields:**
- Personal info: full name, preferred name, pronouns, photo, contact details, date of birth (minor safeguarding gating)
- Skills & interests: free-text skill tags with autocomplete, interest categories mapped to program areas
- Availability: weekly recurring grid (day + time blocks), blackout date ranges, max hours per week/month
- Compliance & credentials: document uploads (ID, certifications, DBS/background checks), expiry alerts at 30/14/7 days, e-signature for policy acceptance
- Emergency contacts
- Custom fields: coordinators can define org-specific fields (dropdowns, text, checkboxes)

**Profile actions:**
- Volunteers self-serve: create, edit, and deactivate their own profile
- Coordinators can edit any profile, merge duplicates, and archive leavers
- Bulk import via CSV/Excel with a field-mapping wizard
- Export individual profile as PDF or full roster as CSV/Excel
- GDPR right-to-erasure: permanently delete PII while retaining anonymised aggregate stats

### 2. Recruitment & Onboarding

**Public Opportunity Listings**
- Coordinators create an Opportunity with title, description, required skills, location, date/time, and spots available
- Each listing auto-generates a shareable public URL and embeddable widget (iFrame) for the org's own website
- Listings are filterable by category, location (map view), date, and commitment level
- SEO-optimised pages with schema.org/VolunteerRole structured data

**Application Pipeline**
- One-click apply for returning volunteers; short-form for new sign-ups
- Custom application questions per opportunity (text, multiple choice, file upload)
- Kanban pipeline for coordinators: Applied → Shortlisted → Approved → Declined
- Bulk approve/decline with templated messaging
- Waitlist management with automatic promotion when a spot opens

**Onboarding Workflows**
- Coordinators build step-by-step onboarding checklists per role or program
- Step types: watch video, read document, complete quiz, upload document, sign form, attend induction session
- Volunteers see a progress bar and can resume on any device
- Automated reminders if onboarding stalls beyond a configurable number of days
- Coordinator dashboard shows completion rates across the cohort

### 3. Scheduling & Shift Management

**Shift Creation**
- Single shift, recurring shift (daily/weekly/custom pattern), and multi-day event wizards
- Shift fields: title, location (address + embedded map), date/time, role(s) needed, spots, coordinator-in-charge, notes
- Shifts grouped into Programs for reporting and access control
- Capacity management: hard cap on volunteers per shift, optional waitlist
- Clone a shift or entire program schedule to a future date range

**Volunteer Self-Scheduling**
- Volunteers browse open shifts in a calendar or list view
- Smart suggestions: shifts matching the volunteer's skills, location, and stated availability surfaced first
- One-tap sign-up with instant confirmation via email/SMS/push
- Volunteers can cancel up to a coordinator-defined cut-off time; late cancellations are flagged
- Swap requests: volunteer proposes a swap with another approved volunteer; coordinator approves

**Coordinator Scheduling Tools**
- Drag-and-drop timeline view to assign or move volunteers between shifts
- Auto-fill: system recommends best-fit volunteers for open slots based on skills and availability; coordinator approves in one click
- Conflict detection: warns on double-bookings or scheduling outside stated availability
- Bulk actions: assign a list of volunteers to a recurring shift series
- Export: print-ready PDF schedule and machine-readable iCal/CSV

**Check-In / Check-Out**
- Coordinator generates a QR code per shift; volunteers scan on arrival
- Coordinator manually marks attendance in a list view with a toggle
- Geofenced auto-check-in: phone detects proximity to venue and prompts check-in (opt-in)
- Late/no-show flagging with automated follow-up message template

### 4. Hour Tracking & Verification

**Logging Methods**
- Auto-log from check-in/check-out events
- Volunteer self-log: submit hours for ad-hoc activities not on the schedule
- Coordinator bulk log: upload a CSV of hours for a whole shift or program

**Approval Workflow**
- Self-logged hours require coordinator approval (or org can configure auto-approve)
- Coordinator sees a pending queue with one-click approve, reject, or edit-and-approve
- Dispute resolution: volunteers can flag a discrepancy on auto-logged hours

**Reporting & Milestones**
- Volunteers see cumulative hours broken down by program and time period on their personal dashboard
- Milestones (e.g. 10, 50, 100, 500 hours) trigger a congratulations message and optional badge
- Coordinator hour reports: by volunteer, program, date range, or location
- Export to CSV/Excel for payroll-equivalency calculations or grant reporting

### 5. Communications

**Messaging**
- In-app direct messaging between coordinators and volunteers (1-to-1 and group)
- Broadcast messages to any segment: all volunteers, program participants, shift attendees, or a custom filter
- Rich-text composer with attachments (PDF, images) and link preview
- Delivery channels: in-app notification, email, SMS (Twilio), WhatsApp (WhatsApp Business API — optional add-on)
- Delivery and read receipts per channel

**Automated Notifications**

| Trigger | Timing |
|---------|--------|
| Shift reminder | 48h and 2h before shift (configurable) |
| Shift cancellation or change | Immediate |
| Onboarding step overdue | Configurable cadence |
| Hour approval / rejection | Immediate |
| Credential expiry warning | 30, 14, and 7 days before |
| Milestone reached | Immediate |
| Volunteer inactivity nudge | After X days without activity |

**Email Templates**
- Pre-built templates for every automated event
- Drag-and-drop template editor with org branding (logo, colours, font)
- Personalisation tokens: `{{first_name}}`, `{{shift_date}}`, `{{program_name}}`, etc.
- A/B testing for subject lines with open-rate tracking

**Announcements & Newsletters**
- Coordinators publish Announcements to the volunteer app feed
- Monthly newsletter builder: drag in hour stats, upcoming events, recognition highlights, and custom content blocks
- Schedule send at a future date/time or send immediately

### 6. Recognition & Engagement

**Badges & Achievements**
- Pre-built badge library: hour milestones, consecutive months active, skills demonstrated
- Coordinators can create custom badges with custom artwork and award criteria
- Badges displayed on volunteer profile and shareable to LinkedIn/social media

**Leaderboards**
- Opt-in leaderboard ranked by hours, shifts completed, or referrals
- Scoped by program, time period, or whole organisation
- Volunteers can opt out of public ranking at any time

**References & Testimonials**
- Coordinator generates a PDF reference letter pre-populated with the volunteer's verified stats
- Volunteer can request a reference through the app; coordinator receives an in-app prompt
- Coordinator can publish a testimonial quote on the volunteer's profile (with their consent)

**Surveys & Feedback**
- Post-shift survey automatically sent to volunteers (NPS + open text, fully customisable)
- Post-program survey for deeper feedback
- Coordinator "Pulse Check" survey sent to the whole roster on demand
- Results aggregated in a feedback dashboard with trend charts

### 7. Reporting & Analytics

**Standard Reports**

| Report | Description |
|--------|-------------|
| Volunteer Summary | Total volunteers by status (active, inactive, pending), growth over time |
| Hours by Program | Total and average hours per program and shift, by date range |
| Retention & Churn | Retention rate, first-time vs. returning volunteers, drop-off analysis |
| Shift Fill Rate | Percentage of shifts fully staffed; unfilled slot trends |
| Onboarding Funnel | Conversion from application to first shift; drop-off at each step |
| Credential Compliance | Percentage of active volunteers with valid credentials on file |
| Impact Statement | Estimated dollar value of volunteered time (using government labour rates) |
| Communication Stats | Email open rates, click rates, opt-out rates |

**Custom Report Builder**
- Drag-and-drop: choose dimensions, metrics, and filters
- Save as a named view and share with other coordinators
- Schedule recurring delivery as PDF or CSV via email

**Executive Dashboard**
- Summary KPI cards: total volunteers, hours this month, active programs, fill rate
- Trend sparklines for key metrics over the last 12 months
- Shareable read-only link for board members or funders (no login required)

### 8. Organisation Administration

**User Roles & Permissions**

| Role | Access |
|------|--------|
| Super Admin | Full access: billing, integrations, all data. Can create/delete any coordinator or program |
| Coordinator | Manage volunteers, shifts, messaging, and reports within assigned programs |
| Read-Only Staff | View dashboards and rosters; cannot modify data |
| Volunteer | Own profile, schedule, messages, and hours only |

- Custom roles: clone a base role and adjust individual permissions
- Program-scoped access: coordinators can be restricted to specific programs

**Organisation Settings**
- Branding: logo, primary colour, email sender name and address
- Timezone and locale (date format, distance units)
- Default notification preferences (overridable per user)
- Volunteer-facing terms of service and privacy policy upload
- Data retention policy configuration

**Multi-Site / Multi-Team**
- Organisation divided into Sites (e.g. city branches) or Teams
- Volunteers and shifts associated with a site; coordinators can manage one or more sites
- Cross-site reporting available to Super Admins

### 9. Integrations & API

**Native Integrations**

| Integration | Description |
|-------------|-------------|
| Google / Outlook Calendar | Two-way sync: shifts in volunteers' personal calendar; cancellations auto-update |
| Salesforce / HubSpot | Sync volunteer records as contacts; log volunteer activity as engagement data |
| Stripe / PayPal | Optional registration fees or event ticket purchases |
| Zapier / Make | No-code automation connecting to 5,000+ apps |
| Slack / Microsoft Teams | Shift reminders and announcements to channels; coordinator alerts via DM |
| Google Forms / Typeform | Import application responses directly into the volunteer pipeline |
| Mailchimp / Klaviyo | Sync volunteer segments for external email marketing |
| Xero / QuickBooks | Export hour valuations for accounting and grant reporting |

**Public REST API**
- RESTful JSON API with OAuth 2.0 authentication
- Endpoints: volunteers, shifts, hours, programs, messages, reports
- Webhooks: push events (shift booked, hour logged, profile created) to external systems in real time
- Rate limits: 1,000 req/hour (standard), 10,000 req/hour (enterprise)
- Interactive API docs via Swagger/OpenAPI

### 10. Mobile App

- Full coordinator and volunteer functionality on iOS and Android
- Offline mode: view schedule and check in without a data connection; syncs on reconnect
- Push notifications for all alert types
- Biometric login (Face ID / fingerprint)
- Dark mode support
- WCAG 2.1 AA accessibility compliance throughout

---

## Non-Functional Requirements

### Performance
- Page load ≤ 2 seconds at P95 on standard broadband
- API response ≤ 500ms at P95 for reads, ≤ 1s for writes
- Supports 10,000 concurrent volunteers across all organisations

### Security & Privacy
- Data encrypted in transit (TLS 1.3) and at rest (AES-256)
- SOC 2 Type II certification target within 12 months of launch
- GDPR, CCPA, and Australian Privacy Act compliance
- Role-based access control enforced at the API layer
- Audit log: every data change recorded with user, timestamp, and before/after values
- Optional SSO via SAML 2.0 or OpenID Connect (Enterprise plan)

### Reliability
- 99.9% monthly uptime SLA (excluding scheduled maintenance)
- Automated daily database backups retained for 30 days
- Point-in-time recovery to within 1 hour
- Public status page with real-time incident reporting

### Scalability
- Horizontally scalable microservices architecture
- Auto-scaling storage and compute to handle seasonal spikes
- Multi-region deployment option for enterprise customers with data residency requirements

---

## Phased Delivery Plan

| Phase | Focus | Key Deliverables |
|-------|-------|-----------------|
| 1 | Foundation | Rails app scaffold, auth, org/user models, volunteer profiles |
| 2 | Recruitment | Opportunity listings, application pipeline, onboarding workflows |
| 3 | Scheduling | Shift management, self-scheduling, check-in/check-out |
| 4 | Hours | Hour logging, approval workflow, milestones |
| 5 | Communications | Messaging, notifications, email templates |
| 6 | Recognition | Badges, leaderboards, surveys |
| 7 | Reporting | Standard reports, custom builder, executive dashboard |
| 8 | Admin & Integrations | Org settings, multi-site, REST API, native integrations |
| 9 | Mobile & Polish | PWA/offline mode, accessibility audit, performance tuning |

---

## Development Task List

See [TASKS.md](TASKS.md) for the full prioritised build task list.

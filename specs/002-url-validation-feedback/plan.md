# Implementation Plan: Improved URL Validation

**Branch**: `[002-url-validation-feedback]` | **Date**: 2026-08-14 | **Spec**: [spec.md](./spec.md)

**Input**: Feature specification from `/specs/002-url-validation-feedback/spec.md`

## Summary

Improve URL input validation feedback so users receive specific, actionable error messages for empty URLs, missing schemes, unsupported schemes, and malformed links, while preserving existing successful behavior for valid http/https submissions and redirect flows.

## Technical Context

**Language/Version**: Ruby 3.3.0, Rails 8.0.5.1

**Primary Dependencies**: rails, pg, redis, rspec-rails, factory_bot_rails

**Storage**: PostgreSQL for canonical short link records; Redis remains unchanged for redirect caching

**Testing**: RSpec model and request specs

**Target Platform**: Server-rendered web application for local and Render deployment

**Project Type**: Rails web application

**Performance Goals**: Preserve current create-link responsiveness; no meaningful latency increase in validation path

**Constraints**: Keep valid URL behavior unchanged; maintain clear UX messaging in HTML and structured validation output in JSON

**Scale/Scope**: Single feature slice focused on validation message quality in existing link creation flow

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- Code Quality by Default: PASS
  - Planned change is scoped to validation message behavior with minimal surface area.
- Testing and Verification: PASS
  - Plan includes model and request-level validation scenarios for regression safety.
- User Experience Consistency: PASS
  - Requirement explicitly improves user feedback clarity and correction guidance.
- Performance Requirements: PASS
  - Validation remains lightweight and synchronous; no new heavy operations introduced.
- Maintainability and Change Safety: PASS
  - Reuses existing model/controller validation flow; no architectural expansion required.

Post-Design Re-check:

- All gates remain PASS after Phase 1 artifact definition. No violations require justification.

## Project Structure

### Documentation (this feature)

```text
specs/002-url-validation-feedback/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
├── contracts/
│   └── url-validation-feedback.md
└── tasks.md
```

### Source Code (repository root)

```text
app/
├── controllers/
│   └── short_links_controller.rb
├── models/
│   └── short_link.rb
└── views/
    └── short_links/
        └── new.html.erb

config/
└── locales/
    └── en.yml

spec/
├── models/
│   └── short_link_spec.rb
└── requests/
    └── short_links_spec.rb
```

**Structure Decision**: Use the existing Rails monolith structure and update only model validation behavior, user-facing form feedback copy, and request/model specs. No new services or storage entities are required for this feature.

## Complexity Tracking

No constitution violations or complexity exceptions identified.

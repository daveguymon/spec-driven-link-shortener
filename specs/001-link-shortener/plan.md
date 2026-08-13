# Implementation Plan: Link Shortener

**Branch**: `001-link-shortener` | **Date**: 2026-08-13 | **Spec**: [spec.md](spec.md)

**Input**: Feature specification from `/specs/001-link-shortener/spec.md`

## Summary

Build a Ruby on Rails web application that accepts long URLs from a landing page, generates a unique eight-character alias, stores the record in PostgreSQL, enforces a two-year expiry, and redirects requests through Redis-backed caching while preserving a polished, responsive user experience. After a successful submission, the landing page will prominently display the generated short URL and provide a quick copy action so the user can share it without retyping or leaving the page. The solution will emphasize reliability, clear validation, and Render-compatible deployment configuration.

## Technical Context

**Language/Version**: Ruby 3.2, Rails 7.2

**Primary Dependencies**: Rails, PostgreSQL adapter, Redis client, RSpec, FactoryBot, Capybara

**Storage**: PostgreSQL for canonical short-link records; Redis for write-through cache with LRU eviction behavior

**Testing**: RSpec for model/request specs; Capybara for UI flow validation; contract smoke checks for redirect behavior

**Target Platform**: Linux web service on Render.com

**Project Type**: web-application

**Performance Goals**: Create-link flow under 3 seconds in normal conditions; redirect latency under 200ms for cached lookups; cache hit path avoids repeated database reads

**Constraints**: Short aliases must be exactly 8 characters, unique, non-sequential, and non-guessable; default TTL is exactly 2 years from creation; successful creation must show the short URL prominently on the landing page with a quick copy action; all deployment config must align with Render platform expectations

**Scale/Scope**: Small-to-medium public utility with a single Rails app, one PostgreSQL database, and one Redis cache instance

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

- **Code Quality by Default**: PASS — the feature will use small model/service boundaries, explicit validation, and readable MVC flows.
- **Testing and Verification**: PASS — request, model, and UI tests are required for creation, redirect, expiry, and validation paths.
- **User Experience Consistency**: PASS — the form and redirect states must be polished, consistent, and mobile-responsive.
- **Performance Requirements**: PASS — Redis-backed cache and LRU eviction align with the spec’s latency and efficiency requirements.
- **Maintainability and Change Safety**: PASS — this feature is a single app with explicit ownership boundaries and a single source of truth for link state.
- **Render deployment requirement**: PASS — deployment config and runtime settings must remain compatible with Render environment expectations.

## Project Structure

### Documentation (this feature)

```text
specs/001-link-shortener/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
├── spec.md              # Source feature specification
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (not created by /speckit-plan)
```

### Source Code (repository root)

```text
app/
├── controllers/
│   ├── links_controller.rb
│   └── redirects_controller.rb
├── models/
│   └── short_link.rb
├── services/
│   ├── alias_generator.rb
│   ├── redirect_resolver.rb
│   └── cache_manager.rb
├── views/
│   ├── links/
│   └── layouts/
├── mailers/
└── jobs/

config/
├── routes.rb
├── database.yml
├── initializers/
├── environments/
└── puma.rb

db/
├── migrate/
├── schema.rb
└── seeds.rb

spec/
├── models/
├── requests/
├── system/
├── services/
└── support/
```

**Structure Decision**: Single Rails application with a minimal MVC structure and explicit service objects for alias generation, redirect resolution, and cache operations. This avoids unnecessary microservice complexity while preserving clear ownership and testability.

## Complexity Tracking

No constitution violations require special justification for this feature. The chosen design stays within the project’s governance standards and the app remains intentionally small and maintainable.

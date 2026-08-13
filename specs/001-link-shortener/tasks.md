# Tasks: Link Shortener

## Phase 0: Setup

- [ ] Initialize the Rails application with PostgreSQL and Redis support
- [ ] Configure environment variables and Render-compatible runtime settings
- [ ] Add the required gems for Redis, validation, and testing
- [ ] Create the database and verify the app boots successfully

## Phase 1: Data and domain logic

- [ ] Add the `ShortLink` model with URL validation, alias generation, and expiry rules
- [ ] Implement alias uniqueness generation and collision handling
- [ ] Add the Redis-backed cache service with write-through behavior and LRU eviction
- [ ] Add request and model specs for validity, expiry, and redirect behavior

## Phase 2: Web flow and UX

- [ ] Create the landing page form and submission flow
- [ ] Implement the redirect controller for active links and expired-link handling
- [ ] Build the expired/not-found UI states
- [ ] Add sleek, mobile-responsive styling for the landing page and redirect states

## Phase 3: Integration and validation

- [ ] Run the feature test suite and fix failures
- [ ] Validate the end-to-end create → redirect → expiry paths
- [ ] Confirm the Render configuration and startup settings are aligned with deployment expectations
- [ ] Mark all tasks complete in this document

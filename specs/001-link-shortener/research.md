# Research: Link Shortener

## Decision: Use a single Rails application with explicit service boundaries

The project will be implemented as a single Rails web application with a normal MVC layout and dedicated service objects for alias generation, redirect resolution, and cache management. This keeps the system small, easy to test, and aligned with the feature requirements without introducing unnecessary architectural complexity.

### Rationale
- The product is one public-facing workflow: create a short link, store it, and resolve it.
- A single Rails app is the simplest way to satisfy the PostgreSQL and Redis requirements with clear operational ownership.
- Service objects isolate the non-trivial alias generation and cache logic from controller concerns and make validation simpler.

### Alternatives considered
- Full multi-service architecture: rejected because it adds operational complexity without solving a real product need.
- Direct controller/database logic: rejected because alias generation and cache policies are domain-critical and deserve clear boundaries.

## Decision: Use PostgreSQL as the canonical source of truth and Redis as an in-memory cache layer

All link records and metadata will be stored in PostgreSQL. Redis will be used as a write-through cache to speed repeated redirect lookups and enforce least-recently-used evictions at the cache layer.

### Rationale
- PostgreSQL matches the requirement for durable storage and data integrity.
- Redis provides the required in-memory caching behavior for high-frequency redirect lookups.
- A write-through cache pattern ensures cache and data store remain consistent for reads after writes.

### Alternatives considered
- Cache-only storage with no durable record: rejected because the requirement demands persistent link metadata.
- Database-only reads: rejected because it would not satisfy the caching requirement or performance target.

## Decision: Enforce strict input and expiry validation

The system will only accept valid http/https URLs, generate a unique eight-character alias, and set expiry to exactly two years after creation. Expired links will produce an explicit expired state rather than redirecting.

### Rationale
- The spec explicitly requires valid URLs and an exact alias length.
- Enforcing an exact two-year TTL creates consistent lifecycle behavior and simplifies tests.
- A denial rather than silent redirect for expired links is more predictable and user-friendly.

### Alternatives considered
- Accepting arbitrary strings or missing protocol values: rejected because it creates invalid destination behavior and weakens user trust.
- Variable or user-configurable expiry: rejected because the requirement specifies a fixed default of two years.

## Decision: Use a composed, testable UX and redirect flow

The landing page will remain the main entry point, and successful submissions will return a short URL using the base domain. After creation, the landing page will show the full short URL in a prominent success state and provide a clear copy action so users can distribute it immediately. Redirect requests will validate expiry before performing the redirect.

### Rationale
- This matches the user-facing product flow in the specification.
- It separates creation and resolution concerns while preserving a simple and responsive interface.
- A visible, copyable result reduces friction and aligns with the user’s expectation of immediate value after shortening a URL.

### Alternatives considered
- Creating a separate admin console or analytics dashboard: not required by the specification and would add scope.
- Returning a result in a hidden or non-obvious format: rejected because it weakens trust and fails the requirement to make the short link easy to copy.
- Redirecting without validation or explicit expiration states: rejected because it fails the user trust and reliability requirements.

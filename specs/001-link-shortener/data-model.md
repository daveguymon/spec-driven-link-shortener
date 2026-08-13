# Data Model: Link Shortener

## Core Entities

### ShortLink

Represents a created short link and its lifecycle.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| id | UUID / bigint | Primary key | Rails-generated identifier |
| original_url | string | Required, max length set by app validation | The destination URL to redirect to |
| alias | string | Required, 8 chars, unique | Non-sequential, non-guessable value |
| created_at | datetime | Required | Timestamp of creation |
| expires_at | datetime | Required | Created_at + 2 years |
| is_active | boolean | Default true | Derived from expiry check |
| status | string | enum or derived value | Active or expired |

### CacheEntry

Represents the Redis write-through cache representation of a redirect.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| key | string | Required | Alias or lookup key |
| value | string | Required | Original destination URL |
| expires_at | datetime | Required | Cache TTL aligned with expiry window |
| last_accessed_at | datetime | Required | Used for LRU eviction decisions |

### RedirectLookup

An operational representation of the lookup path, not necessarily a persisted table. It resolves alias → destination and validates expiry status.

| Field | Type | Constraints | Notes |
|-------|------|-------------|-------|
| alias | string | Required | Requested short alias |
| destination_url | string | Required | Target URL from ShortLink |
| is_expired | boolean | Required | Derived from expires_at |

## Relationships

- One `ShortLink` maps to exactly one canonical destination URL.
- A `ShortLink` may be cached in one or more Redis `CacheEntry` records while active.
- A redirect read path resolves through Redis before PostgreSQL and falls back to the database if needed.

## Validation Rules

- `original_url` must be a valid http or https URL.
- `alias` must be exactly 8 characters and unique.
- `expires_at` must be set when the record is created and must remain fixed for the lifetime of the record.
- Redirects to expired links must be denied even if cached metadata exists.

## Lifecycle

1. User submits a valid URL.
2. Alias is generated and uniqueness is enforced.
3. ShortLink record is persisted with created_at and expires_at.
4. Redis cache is populated with the redirect mapping.
5. Redirect requests resolve the alias and validate expiry.
6. Expired links move to an expired state and are not redirected.

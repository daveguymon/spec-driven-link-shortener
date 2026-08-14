# Data Model: Improved URL Validation

## Overview

This feature does not introduce new persisted tables. It refines validation behavior for existing destination URL input and defines clearer feedback objects exposed to users.

## Entities

### ShortLink (existing)

Represents a persisted short link record.

| Field | Type | Constraints | Role in this feature |
|-------|------|-------------|----------------------|
| original_url | string | Required, must be valid http/https URL | Input being validated with descriptive failures |
| alias | string | Required, unique, 8 alphanumeric chars | Unchanged by this feature |
| expires_at | datetime | Required, default two years from creation | Unchanged by this feature |

### ValidationFeedback (logical, non-persisted)

Represents user-facing validation guidance returned after failed URL submission.

| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| field | string | Required | The invalid input field name (original_url) |
| reason | enum | Required | One of: required, missing_scheme, unsupported_scheme, malformed |
| message | string | Required | Human-readable correction guidance |

## Validation Rules

- Empty input maps to reason required with a message indicating a URL is required.
- URL missing a scheme maps to reason missing_scheme with guidance to include http:// or https://.
- URL with non-http/https scheme maps to reason unsupported_scheme with explicit allowed schemes.
- Malformed or unparsable URL maps to reason malformed with a corrective example.
- Valid http/https URLs pass existing create-link flow unchanged.

## Relationships

- One failed ShortLink submission can produce one or more ValidationFeedback entries for original_url.
- ValidationFeedback is generated during form/request processing and is not persisted independently.

## State Transitions

1. User submits URL input.
2. Validation evaluates input classification.
3. If invalid, system returns descriptive ValidationFeedback and remains in editable submission state.
4. If corrected and resubmitted as valid, normal short-link creation proceeds.

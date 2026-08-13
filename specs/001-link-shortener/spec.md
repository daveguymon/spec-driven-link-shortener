# Feature Specification: Link Shortener

**Feature Branch**: `001-link-shortener`

**Created**: 2026-08-13

**Status**: Draft

**Input**: User description: "I am created a Ruby on Rails link shortener web application. Users should be able to submit a longform URL on the landing page and have a unique 8-digit unguessable alias generated that will redirect to the longform URL. Data should be stored in a postgres database. Short links/aliases should have a default expiration of two years from the day of creation. The base url for returned aliases is www.shortlinkinator.com. Redis should be used as a write-through in-memory cache with a least-recently used expiration policy. The UI should be thoughtfully-designed and sleek. It should also be mobile responsive."

## Clarifications

### Session 2026-08-13
- Q: Which URL validation and alias-generation rules should define the short-link contract? → A: Accept only well-formed http/https destination URLs, generate 8-character unique aliases using a non-sequential, non-guessable pattern, and return the alias using the application's configured base URL for the current runtime.
- Q: What is the precise expiry behavior for created links? → A: Each short link expires exactly two years after creation, and the system shows an expired-link state for any link beyond that date.
- Q: How should a successful link creation experience present the generated short link to the user? → A: After a successful submission, the landing page must display the full short URL prominently and include a quick, obvious copy action so the user can transfer it without retyping or navigating away.
- Q: How should the base URL behave in local development versus deployed production environments? → A: In local development, generated short URLs MUST use the local app host, defaulting to http://localhost:3000. In deployed environments, generated short URLs MUST use the configured public base URL for that deployment (for example, a Render domain), and the application MUST not hardcode a single production domain across all runtime environments.

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Create a short link from the landing page (Priority: P1)

A visitor lands on the application and enters a long URL to create a short, shareable destination. The experience should feel fast, clear, and trustworthy, and the user should immediately receive a usable short link for distribution. Once created, the short URL should remain visible on the landing page so the user can review it and copy it quickly.

**Why this priority**: This is the core product flow and the main reason the application exists. If a user cannot create a short link reliably and copy it easily, the product has no viable value.

**Independent Test**: A user can open the landing page, paste a valid long URL, submit it, and immediately see and copy a unique short link without leaving the page.

**Acceptance Scenarios**:

1. **Given** the landing page is open and the user has entered a valid destination URL, **When** the user submits the form, **Then** the system generates a unique short alias and displays the full short URL prominently on the landing page.
2. **Given** the landing page has just returned a success state, **When** the user chooses the copy action, **Then** the short URL is copied quickly and the user can share or use it without retyping it.
3. **Given** the user submits an invalid or empty destination URL, **When** the form is processed, **Then** the system rejects the request and shows a clear validation message.

---

### User Story 2 - Open a short link and land on the long destination (Priority: P1)

A recipient clicks a generated alias and expects to be taken to the original website without friction. The redirect should be dependable, fast, and should respect expiration rules when the link is no longer valid.

**Why this priority**: Redirect reliability is the central promise of a short-link service. A user who cannot reach the destination loses trust in the system.

**Independent Test**: A valid alias resolves to the correct destination URL, while an expired or invalid alias produces a clear user experience instead of a confusing failure.

**Acceptance Scenarios**:

1. **Given** a valid short alias exists and has not expired, **When** a user visits the alias URL, **Then** the system redirects them to the original destination URL.
2. **Given** a short alias has expired, **When** a user visits the alias URL, **Then** the system shows an expiration message or equivalent expired-link experience.

---

### User Story 3 - Use the application on mobile and expect a polished experience (Priority: P2)

A user accesses the service from a phone or tablet and expects the interface to remain clear, responsive, and visually polished. The landing page should adapt to smaller screens without losing clarity or usability.

**Why this priority**: The product is a public utility, and the experience must work across common devices to maximize adoption and comprehension.

**Independent Test**: The landing page remains functional, readable, and aesthetically consistent when viewed on a mobile-sized viewport.

**Acceptance Scenarios**:

1. **Given** a user is on a mobile device, **When** they access the landing page, **Then** the layout reflows cleanly and all main actions remain visible and usable.
2. **Given** a user has a large URL to shorten on mobile, **When** they submit the form, **Then** the resulting UI still feels coherent and the short-link output remains easy to copy and share.

---

### Edge Cases

- What happens when the submitted destination is not a valid URL or is missing a protocol?
- How does the system behave when an alias collision occurs during generation?
- What happens when a user attempts to access a short link that was created but has already expired?
- What happens when the system is under heavy traffic and cache contents are being evicted?

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: The system MUST allow a user to submit a long destination URL from the landing page.
- **FR-002**: The system MUST accept only valid http or https destination URLs and reject empty or malformed submissions with a clear validation message.
- **FR-003**: The system MUST generate a unique short alias with exactly eight characters for each valid submission.
- **FR-004**: The system MUST generate aliases using a non-sequential, non-guessable pattern that avoids predictable collisions and preserves uniqueness at creation time.
- **FR-005**: The system MUST return a short URL in the format <configured-base-url>/<alias> for each successful submission, using the local host default of http://localhost:3000 during development and the deployment's configured public URL in production.
- **FR-006**: The system MUST redirect valid short aliases to their original destination URL.
- **FR-007**: The system MUST assign a default expiration of exactly two years from the date of creation for each short link.
- **FR-008**: The system MUST prevent access to expired short links and show an appropriate expired-link state.
- **FR-009**: The system MUST store link metadata and redirect mappings in durable storage for reliable retrieval.
- **FR-010**: The system MUST cache frequently used redirect lookups using a memory-based, write-through cache with least-recently-used expiration behavior.
- **FR-011**: The system MUST present a polished, thoughtfully designed interface that is visually appealing and easy to understand.
- **FR-012**: The system MUST provide a mobile-responsive experience for common device sizes without reducing core functionality.
- **FR-013**: After a successful short-link creation, the landing page MUST display the generated short URL in a prominent, user-visible result area.
- **FR-014**: The generated short URL MUST include a clear copy action that allows the user to copy it quickly without retyping or leaving the page.

### Key Entities *(include if feature involves data)*

- **ShortLink**: Represents a generated alias, the original destination URL, the created date, and the expiration date for the link.
- **RedirectLookup**: Represents the system’s ability to resolve an alias to its target destination and determine whether the link is still valid.
- **CacheEntry**: Represents a short-lived in-memory copy of a redirect lookup used to reduce repeated lookups while respecting eviction and expiration rules.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: Users can create a valid short link from the landing page in under 3 seconds for standard network conditions.
- **SC-002**: At least 99.9% of valid short links redirect to the correct destination without errors.
- **SC-003**: Ninety-five percent or more of users are able to complete the primary creation flow on the first attempt.
- **SC-004**: Expired links are rejected correctly and users receive a clear expired-link experience without confusion.
- **SC-005**: Every short link created during the feature period is assigned an expiration date set to exactly two years after creation.
- **SC-006**: The interface remains usable and visually coherent across mobile and desktop screen sizes.
- **SC-007**: Frequently accessed links are served from the cache with reduced latency while remaining accurate and current.
- **SC-008**: After a successful creation, at least 95% of users can identify and copy the generated short URL without additional guidance or page navigation.

## Assumptions

- The application is a public-facing utility and does not require user accounts for basic short-link creation.
- Alias generation is handled by the system and does not require manual user input.
- Users expect a simple, low-friction experience with minimal onboarding.
- Destination URLs will generally be valid web links, though invalid input must still be handled gracefully.
- The product is expected to support common desktop and mobile browsers without requiring a dedicated app experience.
- The system must generate short URLs relative to the current runtime environment: local development defaults to http://localhost:3000, while deployed environments use the configured public base URL for that deployment.

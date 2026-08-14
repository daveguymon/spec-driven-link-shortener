# Research: Improved URL Validation

## Decision: Provide error messages by validation failure type

Validation feedback will distinguish among empty input, missing URL scheme, unsupported scheme, and malformed URL structure so users can self-correct quickly.

### Rationale
- The feature goal is descriptive guidance, not generic rejection.
- Distinct messages reduce repeated failed submissions.
- This aligns with the constitution requirement that blocked user actions explain what happened and what to do next.

### Alternatives considered
- Single generic invalid URL message for all failures: rejected because it does not meet UX clarity goals.
- Silent inline highlighting without text explanation: rejected because it does not provide corrective guidance.

## Decision: Keep scheme policy strict to http and https only

The accepted protocol policy remains unchanged: only http:// and https:// are valid destination schemes.

### Rationale
- Existing product behavior and security posture rely on this boundary.
- The new feature is messaging clarity, not expansion of allowed protocols.
- Preserves compatibility with existing redirect safety checks.

### Alternatives considered
- Allow additional schemes (ftp, mailto, custom app protocols): rejected as scope expansion and potential security risk.
- Auto-prepend https:// to scheme-less input: rejected because implicit transformation can hide user intent and create surprising behavior.

## Decision: Preserve current successful path for valid URLs

Validation improvements must not alter the behavior of valid submissions, alias generation, expiration rules, or redirect behavior.

### Rationale
- Feature requirements explicitly require unchanged valid http/https flow.
- Limits regression risk by keeping core creation and redirect logic intact.

### Alternatives considered
- Refactor creation workflow while updating messages: rejected as unnecessary complexity for this scope.

## Decision: Validate messaging in both model and request-level tests

Test coverage will include model-level validation outcomes and request-level response behavior for HTML/JSON submissions.

### Rationale
- Model tests verify precise failure classification and message semantics.
- Request tests verify user-visible behavior in real execution paths.
- Supports constitution requirements for verification and change safety.

### Alternatives considered
- Controller-only tests: rejected because they do not guarantee model validation semantics.
- Model-only tests: rejected because they do not confirm request/response UX behavior.

## Decision: Use model-level, reason-specific validation failures with consistent response mapping

Validation should classify failures using distinct reasons (required, missing_scheme, unsupported_scheme, malformed) at the model layer, then expose those messages consistently in both HTML and JSON response paths.

### Rationale
- Keeping validation in one place prevents controller/model drift.
- Distinct failure reasons make UX feedback specific and testable.
- Consistent message mapping supports predictable behavior across interface types.

### Alternatives considered
- Implement separate validation logic in controller for JSON and view for HTML: rejected because duplicated logic risks inconsistent feedback.
- Return multiple simultaneous error reasons for one malformed input: rejected because it increases cognitive load and makes correction less clear.

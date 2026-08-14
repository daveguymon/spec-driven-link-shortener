# URL Validation Feedback Contract

## Purpose

Define externally observable behavior for link-creation validation failures so users receive descriptive, actionable feedback.

## Endpoint

POST /links

Accepts a destination URL submission for short-link creation.

## Request Shape

Form or JSON payload includes:

- short_link[original_url] for HTML form submissions
- short_link.original_url for JSON submissions

## Success Behavior (unchanged)

When original_url is a valid http/https URL:

- Response indicates successful creation.
- Generated short URL is returned in the existing response format.

## Validation Failure Behavior

When original_url is invalid, response must include descriptive reason-specific guidance.

### Failure Case: Required Input

Condition:
- URL value is blank or missing.

Required feedback:
- Message clearly states a destination URL is required.
- Example message: Please enter a destination URL.

### Failure Case: Missing Scheme

Condition:
- URL looks like a host/path but does not include a scheme prefix.

Required feedback:
- Message states URL must start with http:// or https://.
- Message includes corrective guidance to resubmit with one of those prefixes.
- Example message: must start with http:// or https:// (example: https://example.com).

### Failure Case: Unsupported Scheme

Condition:
- URL uses a scheme other than http or https.

Required feedback:
- Message states only http:// and https:// are accepted.
- Example message: must use http:// or https://. Other schemes are not supported.

### Failure Case: Malformed URL

Condition:
- URL cannot be interpreted as a valid web destination.

Required feedback:
- Message states URL format is invalid and should be corrected.
- Example message: is not a valid URL. Please enter a full URL like https://example.com/page.

## Response Contract for JSON Submissions

- HTTP status: 422 Unprocessable Entity for validation failures.
- Response body includes field-level errors for original_url.
- Error text must be specific enough to identify one of the failure cases above.

## Response Contract for HTML Submissions

- Rendered form returns with validation feedback near the URL input.
- Validation text must distinguish required-input failures from scheme-format failures.
- User can correct value and resubmit in the same flow.

## Non-Goals

- Adding new accepted URL schemes.
- Auto-correcting or auto-prepending schemes.
- Changing alias generation, expiration, or redirect behavior.

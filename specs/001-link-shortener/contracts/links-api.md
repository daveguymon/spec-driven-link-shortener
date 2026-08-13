# Links API Contract

## Overview

This contract defines the public behavior for creating and resolving short links in the web application.

## POST /links

Creates a short link from a submitted long URL.

### Request

```json
{
  "url": "https://example.com/very/long/path"
}
```

### Success response

```json
{
  "short_url": "https://www.shortlinkinator.com/AB12CD34",
  "expires_at": "2028-08-13T00:00:00Z"
}
```

### Validation error response

```json
{
  "error": "Please provide a valid http or https URL."
}
```

## GET /:alias

Resolves a short alias to the original destination URL.

### Success response

- HTTP 301 or 302 redirect to the original URL.
- Redirect target is the exact destination stored for the link.

### Expired link response

- HTTP 410 Gone or equivalent expired-link landing page.
- User sees a clear expired-link state without redirecting.

### Not found response

- HTTP 404 Not Found.
- User sees a friendly message indicating the link does not exist.

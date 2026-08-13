# Quickstart Validation Guide

## Prerequisites

- Ruby 3.2+
- Rails 7.2+
- PostgreSQL running locally or in a supported environment
- Redis running locally or in a supported environment
- Render-compatible environment variables configured for local testing

## Setup

1. Install dependencies with Bundler.
2. Create and migrate the PostgreSQL database.
3. Start Redis and confirm connectivity.
4. Configure environment variables for the application URL and cache.
5. Start the Rails server.

## Validation scenarios

### 1. Create a short link

- Open the landing page.
- Submit a valid https://example.com URL.
- Confirm the app returns a short URL in the required format.
- Confirm the alias is 8 characters and unique.

### 2. Redirect a valid alias

- Visit the returned short URL.
- Confirm the browser is redirected to the original destination.
- Confirm the redirect behavior completes without error.

### 3. Validate expiry behavior

- Create a short link and confirm expiration date is set to two years from creation.
- Simulate or test an expired record and confirm the application shows the expired-link state rather than redirecting.

### 4. Validate cache behavior

- Request a popular alias repeatedly.
- Confirm the Redis cache is populated and subsequent read latency is reduced.
- Confirm least-recently-used eviction keeps working under cache pressure.

### 5. Validate mobile responsiveness

- Load the landing page in a mobile viewport.
- Confirm the form is usable, readable, and visually coherent without layout breakage.

## Expected outcomes

- Successful link creation produces a working alias and clear user feedback.
- Redirects work for valid, active links.
- Expired and invalid links are rejected gracefully.
- The interface remains usable and visually polished across screen sizes.

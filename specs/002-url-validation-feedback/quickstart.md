# Quickstart Validation Guide

## Feature

Improved URL validation messaging for link creation failures.

## Prerequisites

- Ruby 3.3.0
- Bundler installed
- PostgreSQL running
- Redis running
- Dependencies installed with bundle install

## Setup

1. Run database setup.
2. Start the Rails app.
3. Keep a second terminal available for tests.

Suggested commands:

- bin/rails db:create db:migrate
- bin/rails server

## Validation Scenarios

### 1. Empty URL input shows required message

1. Open the landing page.
2. Submit without entering a destination URL.
3. Confirm the error states a URL is required.
4. Confirm the message is distinct from invalid-format or scheme-related messages.

Expected result:
- User sees the message: Please enter a destination URL.
- User can immediately correct and resubmit.

### 2. Missing scheme shows corrective guidance

1. Submit example.com/path.
2. Confirm the error explicitly says the URL must start with http:// or https://.
3. Correct input to https://example.com/path and resubmit.

Expected result:
- First attempt shows the message: must start with http:// or https:// (example: https://example.com).
- Second attempt succeeds using normal link creation behavior.

### 3. Unsupported scheme shows allowed schemes

1. Submit ftp://example.com.
2. Confirm the error explains only http:// and https:// are accepted.

Expected result:
- User receives the message: must use http:// or https://. Other schemes are not supported.

### 4. Regression check for valid URLs

1. Submit https://example.com.
2. Confirm a short URL is generated and shown as before.

Expected result:
- Valid URL flow remains unchanged.

## Test Commands

- bundle exec rspec spec/models/short_link_spec.rb
- bundle exec rspec spec/requests/short_links_spec.rb

## Contract and Data References

- API/response behavior: [contracts/url-validation-feedback.md](contracts/url-validation-feedback.md)
- Validation entities and rules: [data-model.md](data-model.md)

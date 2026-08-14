# Tasks: Improved URL Validation

**Input**: Design documents from /specs/002-url-validation-feedback/

**Prerequisites**: plan.md (required), spec.md (required for user stories), research.md, data-model.md, contracts/

**Tests**: Include model and request specs because the plan explicitly requires RSpec verification for affected behavior.

**Organization**: Tasks are grouped by user story so each story can be implemented and validated independently.

## Format: [ID] [P?] [Story] Description

- [P]: Can run in parallel (different files, no dependencies)
- [Story]: User story label (US1, US2, US3)
- Every task includes an exact file path

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Prepare validation-message scaffolding and baseline test targets.

- [X] T001 Add descriptive URL validation message keys and examples in config/locales/en.yml
- [X] T002 Document validation feedback cases and expected JSON/HTML outcomes in specs/002-url-validation-feedback/contracts/url-validation-feedback.md
- [X] T003 [P] Add quick validation execution checklist for local dev runs in specs/002-url-validation-feedback/quickstart.md

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Establish shared validation classification behavior before user-story-specific work.

**CRITICAL**: No user story work starts until this phase is complete.

- [X] T004 Implement URL failure classification branches (missing_scheme, unsupported_scheme, malformed) in app/models/short_link.rb
- [X] T005 [P] Ensure blank-input validation remains distinct and does not collapse into scheme errors in app/models/short_link.rb
- [X] T006 [P] Normalize whitespace and parse-safety handling for destination URL validation in app/models/short_link.rb
- [X] T007 Ensure JSON validation response preserves field-specific descriptive messages in app/controllers/short_links_controller.rb

**Checkpoint**: Shared validation behavior is ready for story-level implementation.

---

## Phase 3: User Story 1 - Get actionable validation guidance (Priority: P1) MVP

**Goal**: Users receive precise, corrective messages for missing scheme and unsupported scheme submissions.

**Independent Test**: Submit example.com/path and ftp://example.com, confirm messages explicitly require http:// or https:// and explain accepted schemes.

### Tests for User Story 1

- [X] T008 [P] [US1] Add model specs for missing scheme, unsupported scheme, and malformed URL messages in spec/models/short_link_spec.rb
- [X] T009 [P] [US1] Add JSON request specs asserting descriptive validation message text for invalid schemes in spec/requests/short_links_spec.rb

### Implementation for User Story 1

- [X] T010 [US1] Implement reason-specific model validation messages for scheme failures in app/models/short_link.rb
- [X] T011 [US1] Render descriptive model errors in the submission feedback area in app/views/short_links/new.html.erb
- [X] T012 [US1] Align JSON error contract examples with implemented scheme failure messages in specs/002-url-validation-feedback/contracts/url-validation-feedback.md

**Checkpoint**: US1 is independently functional and testable.

---

## Phase 4: User Story 2 - Preserve clear feedback for empty input (Priority: P2)

**Goal**: Empty input shows a required-field message that is clearly different from invalid-format and scheme errors.

**Independent Test**: Submit blank URL and confirm required-field wording differs from scheme-related wording.

### Tests for User Story 2

- [X] T013 [P] [US2] Add model spec proving blank URL triggers required-field message distinct from scheme messages in spec/models/short_link_spec.rb
- [X] T014 [P] [US2] Add HTML request spec confirming blank submission displays distinct required-input feedback in spec/requests/short_links_spec.rb

### Implementation for User Story 2

- [X] T015 [US2] Adjust validation ordering and message mapping to preserve distinct blank-input feedback in app/models/short_link.rb
- [X] T016 [US2] Update form error presentation so required-input feedback is visually and textually distinct in app/views/short_links/new.html.erb

**Checkpoint**: US2 is independently functional and testable.

---

## Phase 5: User Story 3 - Recover quickly after failed attempt (Priority: P3)

**Goal**: After a failed attempt, users can correct the URL and successfully submit on the next try without friction.

**Independent Test**: Submit invalid URL, correct it to a valid https URL, then confirm successful short-link creation in same flow.

### Tests for User Story 3

- [X] T017 [P] [US3] Add request spec for invalid-then-corrected resubmission flow in spec/requests/short_links_spec.rb
- [X] T018 [P] [US3] Add request regression spec confirming valid URL create behavior and short URL response remain unchanged in spec/requests/short_links_spec.rb

### Implementation for User Story 3

- [X] T019 [US3] Ensure create action preserves editable form state and returned feedback after validation failure in app/controllers/short_links_controller.rb
- [X] T020 [US3] Ensure corrected resubmissions are handled cleanly in the same form flow in app/views/short_links/new.html.erb

**Checkpoint**: US3 is independently functional and testable.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Final consistency checks, documentation updates, and verification.

- [X] T021 [P] Update feature summary and validation-feedback behavior notes in README.md
- [X] T022 Run targeted regression suite and keep assertions aligned in spec/models/short_link_spec.rb
- [X] T023 Run targeted regression suite and keep assertions aligned in spec/requests/short_links_spec.rb
- [X] T024 Validate end-to-end checklist completion and final expected outcomes in specs/002-url-validation-feedback/quickstart.md

---

## Dependencies & Execution Order

### Phase Dependencies

- Setup (Phase 1): No dependencies
- Foundational (Phase 2): Depends on Setup; blocks all user stories
- User Stories (Phase 3-5): Depend on Foundational completion
- Polish (Phase 6): Depends on completion of desired user stories

### User Story Dependencies

- US1 (P1): Starts after Foundational; no dependency on other stories
- US2 (P2): Starts after Foundational; independent from US1 but can reuse shared validation branches
- US3 (P3): Starts after Foundational; depends on maintained behavior from US1/US2 but remains independently testable

### Within Each User Story

- Tests before implementation
- Model changes before controller/view adjustments where applicable
- UI/response contract alignment after behavior changes

---

## Parallel Opportunities

- Phase 1: T003 can run in parallel with T001-T002
- Phase 2: T005 and T006 can run in parallel after T004 starts
- US1: T008 and T009 can run in parallel; T011 and T012 can run in parallel after T010
- US2: T013 and T014 can run in parallel
- US3: T017 and T018 can run in parallel
- Polish: T021 can run in parallel with T022-T023

---

## Parallel Example: User Story 1

```bash
# Parallel test authoring for US1
Task T008 in spec/models/short_link_spec.rb
Task T009 in spec/requests/short_links_spec.rb

# Parallel post-validation updates for US1
Task T011 in app/views/short_links/new.html.erb
Task T012 in specs/002-url-validation-feedback/contracts/url-validation-feedback.md
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 and Phase 2.
2. Complete US1 tasks (T008-T012).
3. Validate US1 independent test criteria.
4. Demo/deploy MVP behavior improvement.

### Incremental Delivery

1. Ship US1 for high-impact descriptive messaging.
2. Add US2 for required-field clarity.
3. Add US3 for smooth correction-and-resubmit UX.
4. Execute Phase 6 polish and full regression pass.

### Parallel Team Strategy

1. One developer handles model validation core in app/models/short_link.rb.
2. One developer handles request/model spec tasks in spec/models/short_link_spec.rb and spec/requests/short_links_spec.rb.
3. One developer handles form feedback updates in app/views/short_links/new.html.erb and docs alignment in specs/002-url-validation-feedback/contracts/url-validation-feedback.md.

---

## Notes

- Tasks marked [P] are safe parallel candidates with minimal file overlap.
- Each story phase is scoped for independent validation.
- Keep message text consistent between model errors, HTML rendering, and JSON responses.

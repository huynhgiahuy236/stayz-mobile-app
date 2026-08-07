# StayZ Release Candidate Audit Checklist

## Table of contents

1. Scope and inspection coverage
2. UI review
3. UX review
4. Functional review
5. User-flow review
6. Navigation review
7. Consistency review
8. Business-logic review
9. Edge cases
10. Language review
11. Accessibility review
12. Performance perception
13. Backlog schema
14. Grouping and release-readiness output

## 1. Scope and inspection coverage

Inspect every screen, feature, navigation path, user interaction, transition, booking flow, and discoverable edge case. Start the report with a coverage matrix listing each screen/flow and whether it was runtime-observed, source-inspected, unavailable, or out of scope.

Never equate source inspection with runtime verification. State missing credentials, unavailable services, unsupported devices, or absent flows as limitations.

## 2. UI review

Review visual hierarchy, typography and font consistency, spacing, margins, padding, alignment, grid rhythm, cards, buttons, inputs, icons, image quality, shadows, border radii, elevation, semantic colors, disabled/loading/empty/error/success/warning states, skeletons, balance, density, Material consistency, responsiveness, SafeArea, status bar, bottom navigation, app bars, floating actions, dialogs, bottom sheets, snackbars, badges, chips, ratings, price displays, and hotel/room/booking/review/favorite cards.

## 3. UX review

Review ease of use, cognitive load, information hierarchy, booking and search journeys, discoverability, calls to action, feedback, animation timing, touch targets, one-hand use, accessibility, error prevention and recovery, confirmation, undo, loading perception, micro-interactions, and user confidence.

## 4. Functional review

Inspect buttons, icons, menus, search, filters, sorting, date picker, guest and room selectors, favorites, reviews, ratings, profile, notifications, payment, booking, cancellation, rebooking, logout, login, registration, and forgot-password behavior.

Every actionable control must have a logical destination, visible feedback, valid result, and safe failure path. Mark absent expected capabilities as `Not implemented`; do not invent requirements that the product never claims to support.

## 5. User-flow review

Trace at minimum:

Splash -> Authentication -> Home -> Search -> Hotel detail -> Room selection -> Booking detail -> Payment -> Booking success -> Upcoming booking -> Completed booking -> Hotel review -> Profile.

Also trace alternate and failure branches. Identify missing or duplicate steps, unnecessary screens, dead ends, broken or circular navigation, excessive depth, and confusing state changes.

## 6. Navigation review

Check app back, system back, iOS swipe-back where applicable, bottom navigation, tabs, nested navigation, stack push/pop/replace behavior, deep links if present, and restoration after authentication/payment. No screen may trap the user or accumulate unintended duplicate history.

## 7. Consistency review

Check naming, terminology, language, capitalization, icons, colors, buttons, animations, cards, spacing, typography, layout, component reuse, date/currency/price/time formats, rating display, status and booking labels, profile labels, and filter behavior against a single coherent design system.

## 8. Business-logic review

Validate booking status transitions; cancelled/completed placement; payment-to-booking updates; favorite synchronization; review eligibility after completed stays; guest/date/room validation; availability; totals, taxes and discounts; price consistency; and status-dependent action visibility.

Trace real schema, repository, API, and service behavior. Check concurrency, idempotency, stale data, duplicate submission, timezone boundaries, partial failures, and authorization where relevant.

## 9. Edge cases

Inspect no internet, API failure, indefinite loading, empty hotel list, no results, payment or booking failure, image failure, large text, small devices, tablets, landscape, long names, large prices, missing avatar, deleted booking, invalid or boundary dates, expired sessions, rapid repeated taps, app background/resume, and stale availability.

## 10. Language review

Review grammar, spelling, capitalization, button labels, validation and error messages, snackbars, dialogs, professional tone, terminology, and unintended mixed language.

## 11. Accessibility review

Review contrast, minimum touch target size, text scaling, screen-reader names/roles/states, focus order, color-blind safety, one-hand usability, meaningful image labels, form labels/hints/errors, reduced-motion behavior, and layout at enlarged text sizes.

Use WCAG 2.2 AA as the baseline where measurable: 4.5:1 normal text, 3:1 large text and essential graphical objects. Use platform touch-target expectations: at least 48x48dp on Android and 44x44pt on iOS.

## 12. Performance perception

Review animation smoothness, perceived loading speed, skeletons, lazy loading, placeholders, pull-to-refresh, transition quality, image sizing/caching, list behavior, unnecessary rebuild risk, duplicate requests, and feedback during slow operations.

## 13. Backlog schema

Each task must include:

- Task ID
- Category
- Screen
- Evidence confidence (`Observed`, `Source-confirmed`, `Risk`, `Not implemented`)
- Priority
- Severity
- Difficulty
- Estimated time
- Current problem
- Root cause
- Why it matters
- Recommended solution (no code)
- Acceptance criteria
- Potential side effects
- Dependencies

## 14. Grouping and release-readiness output

Group tasks by priority: Critical, High, Medium, Low.

Also categorize tasks by UI, UX, Navigation, Business Logic, Accessibility, Performance, Consistency, Design System, Booking, Search, Payment, Profile, Favorites, Reviews, and Authentication. A task may have multiple category tags.

Score from 1 to 10:

- UI
- UX
- Navigation
- Consistency
- Accessibility
- Business Logic
- Booking Flow
- Performance
- Visual Design
- Overall Product Quality

Provide a short evidence-based rationale for every score, then give the release verdict and mandatory release gates.

List exactly 20 entries in each requested section when evidence supports distinct entries:

- Top 20 UI issues
- Top 20 UX issues
- Top 20 functional issues
- Top 20 navigation issues
- Top 20 logic issues
- Top 20 consistency issues
- Top 20 minor issues
- Top 20 polish improvements

Do not pad lists with fabricated or duplicate findings. If fewer than 20 evidence-backed entries exist, list the available entries and explicitly state the verified count.

Stop after the audit. Do not implement, modify, redesign, or generate code until the user approves selected backlog tasks.

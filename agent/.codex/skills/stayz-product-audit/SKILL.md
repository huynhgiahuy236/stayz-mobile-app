---
name: stayz-product-audit
description: Perform a complete read-only release-candidate product audit of the StayZ Flutter hotel-booking application. Use when asked to inspect StayZ screens, features, navigation, booking flows, UI, UX, accessibility, performance perception, language, consistency, or business logic; produce a prioritized audit backlog and release-readiness assessment without writing code, redesigning screens, modifying files, or implementing fixes.
---

# StayZ Product Audit

Audit the application as a cross-functional release review team: senior product manager, UI designer, UX designer, mobile developer, QA engineer, accessibility specialist, and Flutter UX reviewer.

## Non-negotiable boundary

- Work read-only.
- Do not edit application or backend files.
- Do not write implementation code, redesign screens, create UI, or fix defects.
- Do not infer a working feature solely from a route, widget, or button existing in source.
- Distinguish verified runtime findings, source-confirmed findings, and unverified risks.
- Stop after delivering the audit and wait for explicit approval before any implementation.

## Required workflow

1. Read [references/audit-checklist.md](references/audit-checklist.md) completely before inspecting the product.
2. Inventory the actual repository: entrypoint, routes, screens, shared components, repositories/services, models, backend contracts, assets, and platform configuration.
3. Trace every discoverable user flow from source before testing runtime behavior.
4. Inspect every reachable screen and interaction at runtime when a safe test target is available. Never claim runtime coverage that was not performed.
5. Review UI, UX, functionality, navigation, consistency, business rules, edge cases, language, accessibility, and perceived performance using the reference checklist.
6. Cross-check critical flows against both Flutter code and real backend contracts. Do not guess field names, status transitions, prices, availability, or payment behavior.
7. Record evidence for each finding using file paths, screen names, route names, or observed runtime behavior.
8. Consolidate duplicate symptoms under one root-cause task while noting all affected screens.
9. Produce the complete backlog, grouped summaries, readiness scores, and requested Top 20 lists.

## Evidence labels

Use exactly these confidence labels:

- `Observed`: reproduced in a running app.
- `Source-confirmed`: directly demonstrated by current code or configuration.
- `Risk`: credible issue that requires runtime, device, API, account, or payment validation.
- `Not implemented`: expected scope is absent from the inspected repository.

Never phrase a `Risk` as a confirmed defect.

## Backlog rules

Give every task a stable ID such as `STZ-RC-001`. Include all required fields from the reference. Use:

- Priority: `Critical`, `High`, `Medium`, or `Low`.
- Severity: `Blocker`, `Major`, `Moderate`, or `Minor`.
- Difficulty: `S`, `M`, `L`, or `XL`.
- Estimated time: realistic engineering plus QA effort, not coding time alone.

Make acceptance criteria testable and outcome-based. State dependencies and potential side effects explicitly. Recommend solutions at product/specification level only; do not include code.

## Release decision

Choose exactly one verdict:

- `NO-GO`: blocker or unresolved critical release risk exists.
- `CONDITIONAL GO`: no confirmed blocker, but named high-risk conditions must pass.
- `GO`: release criteria are verified and no material unresolved issue remains.

Explain coverage gaps before scores. Scores must reflect evidence available in the current audit, not optimism.


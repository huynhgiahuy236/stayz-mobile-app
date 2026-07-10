# StayZ Booking Assistant Skill Package

This package teaches future AI agents how to plan or implement a grounded conversational booking assistant without duplicating or bypassing StayZ's existing booking flow.

## Reading order

Start with `SKILL.md`, then read `PROJECT_CONTEXT.md`, `SAFETY_AND_CONFIRMATION.md`, `INTENT_SCHEMA.md`, `CONVERSATION_RULES.md`, `RECOMMENDATION_RULES.md`, `NAVIGATION_CONTRACT.md`, `IMPLEMENTATION_READINESS.md`, and `EXAMPLES.md`.

## Scope

The package is documentation only. It does not implement chat UI, APIs, database changes, navigation, booking creation, or payment. Project-specific claims are source-confirmed where possible; uncertain contracts are explicitly labeled.

## Current readiness

Status: **Partially ready**. StayZ already has real hotel/room/booking models, API/repository layers, search and date-aware room inventory, named booking routes, a protected AI chat endpoint, and a Flutter chat sheet. Structured recommendation payloads, assistant state ownership, privacy/analytics requirements, and complete tests are not confirmed.

## Maintenance

Whenever routes, DTOs, backend models, repository methods, AI response contracts, authentication, availability or payment behavior changes:

1. Reinspect current source.
2. Update `PROJECT_CONTEXT.md` evidence and snapshot date.
3. Refresh field mappings in `INTENT_SCHEMA.md` and `NAVIGATION_CONTRACT.md`.
4. Reassess every readiness status.
5. Keep examples aligned with supported behavior and never add fabricated inventory.

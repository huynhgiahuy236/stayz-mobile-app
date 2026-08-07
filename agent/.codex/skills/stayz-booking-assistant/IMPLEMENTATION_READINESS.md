# Implementation Readiness

Snapshot: 2026-07-10. Status meanings: Ready, Partially ready, Not ready, Not found.

| Check | Status | Evidence / next requirement |
|---|---|---|
| Chat API availability | Ready | Protected `POST /ai/chat`; backend route/controller/service and Flutter caller exist |
| OpenAI environment configuration | Partially ready | Keys/model documented in `.env.example`; actual runtime secret/config not verified |
| Backend integration approach | Ready | AI service returns structured `{ success, reply, conversationId, intent, suggestions }`; Flutter chat sheet consumes `suggestions` and maps them to `RoomSelectionArgs` |
| Database mappings | Partially ready | Property/room/booking fields confirmed; several intent fields have no mapping |
| Search endpoint | Ready | `GET /properties/search` and `SearchFilters` confirmed |
| Availability endpoint | Partially ready | `GET /room/:hotelId?checkIn&checkOut` calculates availability; formal standalone endpoint/contract not found |
| Route names | Ready | Named routes confirmed in `AppRoutes` |
| Booking DTO | Ready | `RoomSelectionArgs` and `BookingDraft` confirmed; AI suggestion → `RoomSelectionArgs` adapter implemented in `ai_chat_sheet.dart` with ID revalidation against current repository data |
| State-management integration | Not ready | Local widget state exists; durable/shared assistant intent ownership not defined |
| Error handling | Partially ready | Current chat catches failures; structured retry/stale-result/navigation failures need contract |
| Loading states | Partially ready | `_sending` exists in chat; recommendation/search/navigation loading requirements need validation |
| Analytics requirements | Not found | No confirmed AI booking funnel events or source attribution contract |
| Privacy requirements | Not found | No confirmed AI prompt/history retention and personal-data policy |
| Test strategy | Not ready | No confirmed unit/integration/E2E plan for extraction, ranking, safety and navigation |

## Blocking implementation checklist

- [x] Freeze a machine-readable `/ai/chat` intent/recommendation response contract. (Source-confirmed 2026-07-10: `{ success, reply, conversationId, intent, suggestions }`; see PROJECT_CONTEXT.md.)
- [ ] Define ownership and lifetime of conversation intent state.
- [ ] Confirm date locale/timezone and nights convention across client/server.
- [ ] Confirm reliable ratings/review aggregation; remove reliance on synthetic summary rating.
- [ ] Confirm cancellation, breakfast, special-request and infant semantics or mark unsupported.
- [x] Define recommendation-to-route adapter and back/state restoration. (Implemented: suggestion card → revalidate ID via repository → `/room-selection` with editable `RoomSelectionArgs`; chat sheet stays below the pushed route so back returns to the recommendation context.)
- [ ] Specify price and availability recheck moments.
- [ ] Define privacy, logging, retention, analytics and test requirements.
- [ ] Verify authentication recovery without losing user intent.

Overall status: **Partially ready**. Core data, search, availability, AI endpoint, routes and booking DTOs exist, but a stable structured contract, assistant state ownership, privacy/analytics requirements and test strategy remain incomplete.


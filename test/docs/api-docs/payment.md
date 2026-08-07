# Payment API

All routes use the `/payment` prefix. Authenticated routes require
`Authorization: Bearer <access-token>`. The service uses PayOS as the payment
provider and stores payment records against a StayZ booking.

## Customer endpoints

### `POST /payment/create/:bookingId`

Creates or reuses a PayOS payment link for a booking owned by the signed-in
user. Optional JSON body:

```json
{ "payment_plan": "deposit_30" }
```

Supported plans are `deposit_30` and `full_100`. The server calculates the
amount; clients must never supply a payable amount.

### `GET /payment/booking/:bookingId`

Returns the payment associated with a booking owned by the signed-in user.

### `POST /payment/cancel/:bookingId`

Cancels an open PayOS payment link. This does not cancel the booking and does
not perform a refund.

## Provider callback

### `POST /payment/webhook`

Public endpoint called by PayOS. The backend verifies the provider signature,
matches the amount and booking, and only then marks the payment as paid and the
booking as confirmed. Configure this URL in PayOS; do not protect it with JWT.
Webhook delivery must be treated as the payment source of truth. Browser return
URLs are informational only.

### `GET /payment/return` and `GET /payment/cancel`

Browser redirect targets after the hosted PayOS flow. They do not change
payment or booking state.

## Admin endpoints

- `GET /payment/getAll` lists payments; admin only.
- `POST /payment/admin/:paymentId/cancel` cancels an open PayOS transaction;
  admin only.

## Booking cancellation and refunds

Refunds are not executed automatically. Before cancellation, call
`GET /booking/:bookingId/cancellation-quote`. Cancelling through
`PATCH /booking/:bookingId/status` with `{ "status": "cancelled" }` records
the server-calculated amount and sets `refund_status` to `pending_manual` when
a paid booking is eligible. Operations must process that request separately
and explicitly mark it completed or failed; the UI must not describe a pending
request as money already refunded.

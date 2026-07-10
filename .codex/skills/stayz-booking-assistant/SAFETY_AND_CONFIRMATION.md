# Safety and Confirmation

The user controls every transaction.

## Prohibited autonomous actions

Never automatically create, pay, cancel, edit, or rebook; apply a coupon; select a paid upgrade; accept non-refundable terms; invent availability or prices; bypass authentication/payment/validation; or bypass availability checks.

## Confirmation boundaries

- Searching and summarizing require no transactional confirmation.
- Inferred criteria must be visible and editable.
- Selecting a recommendation only prepares navigation/prefill; it is not booking consent.
- Booking creation requires the user's explicit action on the existing review/confirmation UI.
- Payment requires separate explicit user action and presentation of amount, currency, method, and material terms.
- Cancellation or modification requires the exact booking, consequences, fees/refund terms, and a dedicated confirmation.
- Non-refundable or paid upgrade selections must never be inferred.

## Data integrity and privacy

- Use authenticated user context only through existing supported mechanisms.
- Request no payment credentials in chat.
- Minimize personal data in prompts/logs and follow a confirmed retention policy; current privacy/retention requirements are not confirmed.
- Treat model output as untrusted until IDs, fields, prices and availability are verified against application data.
- On API/model failure, state inability clearly and offer safe manual search; never fill gaps with plausible data.


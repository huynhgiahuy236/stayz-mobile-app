# StayZ

StayZ is a hotel booking capstone project with a Flutter mobile frontend and a Node.js/Express backend.

## Project Layout

- `lib/app`: Flutter app bootstrap, routes, theme, and global configuration.
- `lib/core`: Shared constants, config, utilities, errors, and network helpers.
- `lib/shared`: Reusable UI widgets, layouts, buttons, inputs, cards, dialogs, and loading states.
- `lib/features`: Feature modules such as auth, home, search, hotel, room, booking, payment, favorite, notification, review, chat, profile, and settings.
- `lib/services`: App-level services for API, auth, storage, and uploads.
- `lib/data`: Shared models, repositories, and mock data.
- `assets/design-reference`: UI references for screens, layout samples, and style guide files.
- `backend/stayz_api`: Express REST API organized by routes, controllers, services, models, middlewares, validations, and utilities.
- `docs`: Design system, API docs, database docs, team workflow, and task division.
- `deployment`: Deployment notes for mobile/frontend and backend environments.

## Development Principles

- Keep each large feature in its own module under `lib/features`.
- Put reusable UI in `lib/shared`, not inside individual screens.
- Do not call APIs directly from screens; use services or repositories.
- Backend routes only define routing. Controllers handle request/response. Services contain business logic.
- Keep design references and documentation updated so the team and future agents can follow the same direction.

## Quick Start

```bash
flutter pub get
flutter run
```

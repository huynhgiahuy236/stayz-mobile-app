# StayZ API

Express REST API for the StayZ hotel booking app.

## Folder Roles

- `src/routes`: API endpoint definitions only.
- `src/controllers`: Request parsing and HTTP responses.
- `src/services`: Business logic and orchestration.
- `src/models`: MongoDB/Mongoose schemas.
- `src/middlewares`: Auth, validation, upload, and error handling.
- `src/config`: Environment, database, and third-party service config.
- `src/utils`: Shared helpers such as response format, JWT generation, and pagination.
- `src/validations`: Request validation schemas.
- `uploads`: Local upload storage when not using Cloudinary.

## Commands

```bash
npm install
npm run dev
```

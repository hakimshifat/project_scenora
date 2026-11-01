# SCENORA Backend

Self-contained Dart REST API covering authentication, profiles, movie discovery,
reviews, likes, comments, and follows.

## Run

For the first run, copy `.env.example` to `.env` and put your TMDB credentials
there. The `.env` file is ignored by Git and is loaded automatically, so the
keys do not need to be entered again for every run.

```powershell
Copy-Item .env.example .env
notepad .env
```

```powershell
cd server
dart pub get
dart run bin/server.dart
```

The API starts at `http://0.0.0.0:8080`. Check it with:

```powershell
Invoke-RestMethod http://localhost:8080/health
```

Data persists to `server/data/db.json`. Set `TMDB_API_KEY` and/or
`TMDB_READ_ACCESS_TOKEN` in `.env` to enable live TMDB search/detail results;
without either credential, seeded demo movies are returned. Process environment
variables take precedence over `.env` values.

## Authentication

Send the access token returned by register/login as:

```text
Authorization: Bearer <accessToken>
```

## Main routes

- `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh`, `POST /auth/logout`
- `GET/PATCH /users/me`, `GET /users/<id>`
- `POST /users/<id>/follow`, `GET /users/<id>/followers`, `GET /users/<id>/following`
- `GET /movies/search?q=...`, `GET /movies/popular`, `GET /movies/<id>`
- `GET/POST /reviews`, `GET/PATCH/DELETE /reviews/<id>`
- `POST /reviews/<id>/like`
- `GET/POST /reviews/<id>/comments`, `PATCH/DELETE /comments/<id>`
- `GET /watchlist`, `POST /watchlist/<movieId>`
- `GET/POST /messages`
- `GET /activity`

This is an MVP backend suitable for local demonstration. Production deployment
should replace JSON persistence with PostgreSQL/Firestore and run behind HTTPS.

# Screens and app flow

## What happens at launch

```
Splash ──> Onboarding (first launch only) ──> Login ──> Home
                                               ▲          │
                                               └ sign out / session expired
```

You don't navigate between these by hand. `resolveRedirect` in `lib/app/router/app_router.dart` looks at the session and onboarding state and sends the user to the right place. It re-runs whenever either one changes, so signing in only has to update `authProvider`.

## Screens

| Screen | Route | Notes |
|---|---|---|
| Splash | `/splash` | Shown while the session is restored |
| Onboarding | `/onboarding` | Edit the `_pages` list |
| Login, Register, Forgot password | `/login`, `/register`, `/forgot-password` | Signed-out users only |
| Home (posts example) | `/`, `/posts/:id` | Search, pull to refresh, create, empty and error states |
| Profile, Edit profile | `/profile`, `/profile/edit` | Warns about unsaved changes |
| Settings, About | `/settings`, `/settings/about` | Theme, sign out, version, licenses |
| Terms, Privacy | `/legal/terms`, `/legal/privacy` | **Placeholder text: replace before release** |
| Not found | any unknown path | Also bad deep links such as `/posts/abc` |
| Offline, Maintenance | `/offline`, `/maintenance` | Full-screen versions, see below |
| Component gallery | `/settings/gallery` | Developer catalog, removed from prod builds |

Home, Profile and Settings live in `AppShell`: a bottom bar on phones and a side rail on wide screens. Each tab keeps its own back stack.

## Connecting a real auth backend

Dev and staging set `USE_MOCK_AUTH` to `true`. In that mode any email and password sign in, except `wrong@example.com`, which fails so you can see the error path.

Prod sets it to `false`, and the app then calls these endpoints. Until your API provides them, **signing in on a prod build will fail**.

| Call | Endpoint | Expected response |
|---|---|---|
| Sign in | `POST /auth/login` | `{"token": "...", "user": {...}}` |
| Register | `POST /auth/register` | same as sign in |
| Forgot password | `POST /auth/forgot-password` | anything 2xx |
| Current user | `GET /auth/me` | user object |
| Update profile | `PUT /auth/me` | user object |

A user object is `{"id", "name", "email", "phone", "birthDate"}`. If your API differs, change `ApiAuthRepository` and `User.fromJson`; nothing else needs to know.

## Edge cases already handled

**Sessions**
- A rejected token signs the user out. A late 401 from an old session can't sign out a newer one.
- A wrong password shows "Incorrect email or password", not "session expired".
- The app opens offline using the cached user. A corrupt cache counts as signed out, not a crash.
- Providers with per-user data watch `currentUserIdProvider`, so accounts never see each other's data. **Do this in every per-user provider you add.**
- A deep link opened while signed out resumes after sign in. Only in-app paths are accepted, so `?from=//evil.com` is ignored.
- Forgot password gives the same answer whether or not the account exists.

**Network**
- Offline, timeouts, 403, 404, 429, 503, validation errors and malformed responses each have their own exception and message.
- Riverpod retries only temporary failures, twice, so offline screens appear quickly.
- If a refresh fails, the old data stays on screen and a snackbar explains why.
- Connectivity only drives UI hints. Requests are always attempted, because "connected to Wi-Fi" doesn't guarantee internet access.

**Forms and UI**
- Async buttons ignore repeat taps while running.
- Results that arrive after the screen closed are ignored safely (`runGuarded`, `mounted` checks).
- Text scale is capped at 1.4x. Status views scroll on small screens and with large text.
- In release builds, a widget that throws shows a friendly error instead of a grey box. All uncaught errors go to `AppLogger`, which is where to connect crash reporting.

## Not included

These depend on your product, so add them when you need them:
- Crash reporting and analytics (connect them in `AppLogger`)
- Secure token storage (`flutter_secure_storage`) and token refresh
- Localization (`flutter gen-l10n`)
- Push notifications, an offline data cache, and force-update checks
- Account deletion, which the App Store and Play Store require if users can create accounts in your app

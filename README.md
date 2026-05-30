# Ayojana Hub

Ayojana Hub is an event‑planning marketplace built with **Flutter** and **Firebase**.
Customers create events and request proposals; vendors (catering, photography,
decoration, DJ & music, venue, planning) receive matching opportunities, submit
quotes, negotiate, and — once a customer accepts — a booking is created.

---

## Tech stack

| Layer | Technology |
|------|------------|
| App | Flutter 3.32 (Material, Provider state management) |
| Auth | Firebase Authentication (email/password) |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Messaging | Firebase Cloud Messaging + local notifications |
| Payments | Razorpay |
| Project | `ayojana-hub` |

---

## Roles & core flow

```
CUSTOMER                         VENDOR
   │ create event (status: awaiting_proposals)
   │        └── matched vendors notified by category ──►│ Event Opportunities
   │                                                     │ submit proposal (price, services)
   │ Event ► Proposals  ◄──────────── proposal ─────────┤
   │ negotiate / accept                                  │
   │        └── booking created (status: confirmed) ────►│ My Bookings
```

- **Event** — created by a customer; holds the required service categories.
- **Proposal** — a vendor's quote for an event (or a customer's direct request to a vendor).
- **Booking** — created when a customer accepts a proposal; all other proposals on that event are auto‑rejected.

A vendor handling a **direct request** can **reply with a quote**, **accept**, **reject**,
or **request more info** — each action notifies the customer and updates the proposal status
(`requested → quoted / vendor_accepted / vendor_rejected / info_requested`).

---

## Data model (Firestore)

| Collection | Doc id | Key fields |
|-----------|--------|-----------|
| `users` | `{uid}` | `role` (`customer`/`vendor`/`admin`), name, email, phone, vendor profile fields |
| `vendors` | `{uid}` | `userId` (= uid), name, category, services, rating, location |
| `events` | auto | `userId` (owner), eventName, requiredServices[], status, budget |
| `proposals` | auto | `userId` (event owner), `vendorId` (vendor uid), status, proposedPrice |
| `bookings` | auto | `customerId`, `vendorId`, eventId, proposalId, price, status |
| `notifications` | auto | `userId` (recipient), type, message |
| `conversations` / `messages` | auto | customer/vendor chat |

**Identity rule:** the **Firebase Auth uid is the single canonical key** everywhere.
`users` and `vendors` documents use the uid as their id, and every cross‑entity
reference (`userId`, `vendorId`, `customerId`) stores a uid. This keeps the data,
the queries, and the Firestore security rules consistent.

**Query rule:** because Firestore evaluates list queries against the security rules
(rules are **not** filters), every list query is constrained by the field the rule
authorises, and any ordering/sorting is done **client‑side** rather than with a
Firestore `orderBy` — so the app needs **no composite indexes** to function and a
fresh clone works without provisioning indexes.

---

## Firestore security & indexes

- Rules live in [`firestore.rules`](firestore.rules); composite indexes in
  [`firestore.indexes.json`](firestore.indexes.json) (declared for reference;
  the app no longer depends on them — see the query rule above).
- Deploy with:

  ```bash
  firebase deploy --only firestore:rules,firestore:indexes --project ayojana-hub
  ```

---

## Running the app

```bash
flutter pub get
flutter run                 # device/emulator
flutter run -d chrome       # web
flutter build web --release # production web build (output: build/web)
```

`flutter analyze` is clean (0 errors, 0 warnings).

---

## Test credentials

Run `e2e/seed.mjs` once to create every account below (Auth user + Firestore
`users`/`vendors` profile). The seed is **idempotent** — re‑running signs existing
accounts in instead of erroring, so it always leaves the full test data in place.

**Every account uses the password `Test@1234`.**

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@ayojanahub.test` | `Test@1234` |
| Customer | `customer@ayojanahub.test` | `Test@1234` |
| Vendor — Catering | `catering@ayojanahub.test` | `Test@1234` |
| Vendor — Photography | `photo@ayojanahub.test` | `Test@1234` |
| Vendor — Decoration | `decor@ayojanahub.test` | `Test@1234` |

```bash
cd e2e
npm install            # installs Playwright (first run only)
node seed.mjs          # create/refresh all 5 test accounts + vendor profiles
```

Sign in at the app's login screen with any pair above to exercise that role
(customer dashboard, vendor dashboard, or admin analytics).

---

## End‑to‑end tests & demo (`e2e/`)

The `e2e/` folder is a Playwright + Node harness (build artifacts are git‑ignored).

| Script | Purpose |
|--------|---------|
| `seed.mjs` | Create the Auth users + Firestore profile/vendor docs. |
| `flow-test.mjs` | **Data‑layer e2e** — drives the real Firestore collections / queries / rules as the seeded users and asserts the full lifecycle: event → opportunity → proposal request → reaches vendor → isolation → quote → accept → booking, plus vendor **accept / reject / request‑more‑info** each notifying the customer. **14 assertions, 0 failures.** |
| `demo.mjs` | **UI e2e + video** — drives the live web app like a human and records the full cross‑account story: customer creates an event → catering vendor sees the opportunity and submits a priced proposal → customer reviews the proposal and **accepts** → a confirmed **booking**. |
| `walkthrough.mjs` | **Per‑role UI tour + video** — logs in as every role (customer, two vendors, admin) and visits each role's major screens, screenshotting each. |
| `lib.mjs` | Shared driver helpers (see "Driving Flutter web" below). |

```bash
# 1) serve the web build
python3 -m http.server 8080 --directory build/web

# 2) data-layer assertions (no browser)
cd e2e && node flow-test.mjs

# 3) full story, recorded to e2e/videos/*.webm + screenshots to e2e/screenshots/
URL=http://localhost:8080 node demo.mjs
HEADED=1 URL=http://localhost:8080 node demo.mjs      # watch it live

# 4) per-role screen tour, also recorded
URL=http://localhost:8080 node walkthrough.mjs
```

### Driving Flutter web

Flutter web renders to a **canvas**, so there is no normal DOM to click. Two things
make it automatable:

1. The app calls `SemanticsBinding.ensureSemantics()` on web at startup, so the
   accessibility tree (labels, inputs, buttons) is always present — an
   accessibility win that also lets browser tooling find and drive widgets.
2. `lib.mjs` launches Chromium with **software WebGL (SwiftShader)** so CanvasKit
   renders in headless mode, waits for the semantic tree to finish building, taps
   widgets by their accessibility label (scrolling them into view first), and types
   into Flutter's proxy inputs after focusing them by click.

---

## Notable fixes

- **Vendor opportunities now load.** The opportunities query combined `where(status)`
  with `orderBy(createdAt)` (a composite index that wasn't provisioned) and swallowed
  the failure, so vendors saw "No events available." All such queries are now
  equality‑only with client‑side sorting — no index required.
- **Customers can view & accept vendor proposals.** A vendor's `submitProposal` tried
  to increment the owner's `event.proposalCount`, which the security rules forbid;
  that error aborted the customer notification, and the event screen hid "View
  Proposals" whenever the (now‑stale) count was 0. The increment is best‑effort and
  "View Proposals" is always offered (the proposals screen is the source of truth).
- **Vendor → customer actions are visible.** A vendor's **accept / reject / request
  more info** on a proposal each create a notification for the customer and update the
  visible proposal status.
- **Proposal requests reach vendors.** Proposals are keyed by the vendor's auth uid
  consistently (write + read + rules).
- **Dead code & duplicates removed**, deprecated `withOpacity` migrated to
  `withValues`, and `flutter analyze` brought to 0 errors / 0 warnings.

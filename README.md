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

---

## Firestore security & indexes

- Rules live in [`firestore.rules`](firestore.rules); composite indexes in
  [`firestore.indexes.json`](firestore.indexes.json).
- Deploy with:

  ```bash
  firebase deploy --only firestore:rules,firestore:indexes --project ayojana-hub
  ```

Because Firestore evaluates list queries against the rules (rules are **not**
filters), list queries are always constrained by the field the rule authorises:
vendors read proposals `where('vendorId', '==', myUid)`, and customers read the
proposals on their event `where('userId', '==', myUid)` (every proposal on an
event carries the owner's `userId`), filtering the event client‑side.

---

## Running the app

```bash
flutter pub get
flutter run                 # device/emulator
flutter run -d chrome       # web
flutter build web --release # production web build (output: build/web)
```

---

## Test credentials

Seed the project with `e2e/seed.mjs` (creates the Auth users + Firestore
profiles). All passwords are `Test@1234`.

| Role | Email |
|------|-------|
| Admin | `admin@ayojanahub.test` |
| Customer | `customer@ayojanahub.test` |
| Vendor (Catering) | `catering@ayojanahub.test` |
| Vendor (Photography) | `photo@ayojanahub.test` |
| Vendor (Decoration) | `decor@ayojanahub.test` |

```bash
cd e2e
npm install            # playwright
node seed.mjs          # create test accounts + vendor profiles
```

---

## End‑to‑end tests (`e2e/`)

The `e2e/` folder contains a Playwright + Node harness (git‑ignored build
artifacts):

| Script | Purpose |
|--------|---------|
| `flow-test.mjs` | Data‑layer e2e: drives the real Firestore collections/queries/rules as the seeded users and asserts the full event → proposal → vendor → quote → accept → booking lifecycle. |
| `demo.mjs` | UI e2e: drives the live web app (Flutter canvas via the accessibility tree) and records a video of the full journey. Run visibly with `HEADED=1`. |

```bash
cd e2e
node flow-test.mjs                       # data-layer assertions
HEADED=1 URL=http://localhost:8080 node demo.mjs   # visible UI demo + video (serve build/web first)
```

To serve the web build for the UI demo:

```bash
python3 -m http.server 8080 --directory build/web
```

> Flutter web renders to a canvas. The app calls `SemanticsBinding.ensureSemantics()`
> on web at startup so the accessibility DOM (labels, inputs) is always present —
> an accessibility win that also makes the UI automatable.

---

## Notable fixes

- **Proposal requests now reach vendors.** Proposals are keyed by the vendor's
  auth uid consistently (write + read + rules), and accountless seed vendors were
  removed so requests always target a real vendor account.
- **Customer proposal views & accept flow** use rule‑safe queries (`userId`‑based)
  instead of `eventId`‑only queries that Firestore rejected.
- **Vendor directory** (`vendors/{uid}`) stays in sync when a vendor edits their
  profile; opportunities and notifications are matched by service category.

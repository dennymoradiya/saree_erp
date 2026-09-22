# Saree ERP — Material Accounting, Multi-Item Challan & Production Tracking (100% Dart)

A Flutter + Firebase system for a saree manufacturing business. This is **not**
a basic stock app — it is an auditable ledger system tracking material
movement `SUPPLIER → STITCHING USER → FINISHED SAREE → ADMIN` across two
**independent** accounting dimensions:

1. **Supplier raw-material accounting** (saree/lace/blouse required vs supplied vs pending)
2. **Stitching user / finished-product accounting** (issued vs returned vs pending)

Full requirements: see the original spec you provided — every section number
referenced in code comments (e.g. `§12`, `§52`) maps to that document.
`docs/ARCHITECTURE.md` restates the key rules; `docs/PHASES.md` is the build plan.

## Pure Dart Architecture (No TypeScript / Cloud Functions)

The codebase has been transitioned to **100% pure client-side Dart**:
- All accounting & FIFO engines run in pure Dart (`lib/core/engines/`).
- Admin user creation (Suppliers & Stitching Users) is performed directly via `UserAccountCreationService` utilizing isolated secondary `FirebaseApp` instances and atomic Firestore transactions without terminating the admin's active login session.
- Firestore Security Rules (`firestore.rules`) enforce role-based access (`isAdmin()`) for all transactional writes.
- Unit tests run directly via `flutter test`.

## Getting started

### 1. Flutter app

```bash
flutter pub get
dart pub global activate flutterfire_cli
flutterfire configure   # replaces lib/firebase_options.dart with real values
flutter run
```

### 2. Running Tests

```bash
flutter test
```

### 3. Deploy Firestore Rules & Indexes

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

### 4. Local emulation (optional while developing)

```bash
firebase emulators:start --only auth,firestore
```
# saree_erp

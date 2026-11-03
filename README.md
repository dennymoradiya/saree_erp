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

### 5. Firebase Storage uploads from Netlify

`storage.cors.json` allows the production origin `https://sareesutra.netlify.app`
to access the storage bucket. CORS must be configured on Google Cloud Storage;
Netlify response headers do not control requests to `firebasestorage.googleapis.com`.
Deploying this repository or running `firebase deploy` does not apply this policy.

First open Firebase Console → project `saree-sutra` → Storage and confirm that
Storage is initialized and the bucket is `saree-sutra.firebasestorage.app`.
Complete any required billing/setup steps shown by Firebase. If the console
shows a different bucket, update the `storageBucket` entries in
`lib/firebase_options.dart` and use that bucket in the commands below.

From Google Cloud Shell, or a local Google Cloud CLI authenticated as an account
with permission to update the bucket, run these commands from the repository:

```bash
gcloud storage buckets describe gs://saree-sutra.firebasestorage.app
gcloud storage buckets update gs://saree-sutra.firebasestorage.app --cors-file=storage.cors.json
gcloud storage buckets describe gs://saree-sutra.firebasestorage.app --format="default(cors_config)"
```

The update replaces the bucket's existing CORS policy. If other web applications
use this bucket, retain their origins in `storage.cors.json` before applying it.
The policy does not change Firebase Storage authorization: users must still
sign in and satisfy `storage.rules`.

To check the upload preflight without uploading a file:

```bash
curl -i -X OPTIONS \
  'https://firebasestorage.googleapis.com/v0/b/saree-sutra.firebasestorage.app/o?name=challans%2Fcors-check.jpg' \
  -H 'Origin: https://sareesutra.netlify.app' \
  -H 'Access-Control-Request-Method: POST' \
  -H 'Access-Control-Request-Headers: authorization,content-type,x-firebase-storage-version,x-goog-upload-protocol,x-goog-upload-command,x-goog-upload-header-content-length,x-goog-upload-header-content-type'
```

Expect a successful HTTP status and an `Access-Control-Allow-Origin` header
allowing the site. A 404 preflight can indicate an unavailable or incorrect
bucket; adding CORS alone does not fix that. After resolving the bucket setup,
retry a challan image upload while signed in.
# saree_erp

# users feature

Phase 2 — Admin CRUD for stitching-user profiles (stitching_users/{id}), separate from auth users/{uid}. See lib/features/users/domain/stitching_user_profile.dart.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

## Status
- [x] Stitching user listing (`watchStitchingUsers`) via Riverpod `stitchingUsersListProvider`.
- [x] Admin stitching user creation (`createStitchingUser`) via `createSupplierOrStitchingUser` Cloud Function callable.
- [x] Temporary password generation and display via non-dismissible dialog with WhatsApp copy action.
- [ ] Still open / future passes: Password reset, editing stitching user profiles, and deactivating stitching user accounts.

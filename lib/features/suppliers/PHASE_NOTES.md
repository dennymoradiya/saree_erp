# suppliers feature

Phase 2 — Admin CRUD for supplier profiles (suppliers/{id}). See lib/features/suppliers/domain/supplier.dart.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

## Status
- [x] Supplier listing (`watchSuppliers`) via Riverpod `suppliersListProvider`.
- [x] Admin supplier creation (`createSupplier`) via `createSupplierOrStitchingUser` Cloud Function callable.
- [x] Temporary password generation and display via non-dismissible dialog with WhatsApp copy action.
- [ ] Still open / future passes: Password reset, editing supplier profiles, and deactivating supplier accounts.

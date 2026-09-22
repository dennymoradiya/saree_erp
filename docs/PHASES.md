# Development Phases

Work one phase at a time; don't start the next until the current one is
stable (builds clean, tests pass). Status reflects what this base project
already contains.

- [x] **Phase 1 — Architecture, Firebase setup, Auth, Roles, Routing, Theme.**
      Done in this scaffold: login screen, role-based go_router redirect,
      Material 3 theme, Firestore security rules skeleton, Cloud Functions
      project with both FIFO engines + tests, empty feature folders.
- [ ] **Phase 2 — Products, SKUs/colors, Suppliers, Stitching users.**
      Domain models already exist (`Product`, `ProductSku`, `Supplier`,
      `StitchingUserProfile`). Build repositories + Riverpod controllers +
      admin CRUD screens (list/create/edit, isActive toggle instead of
      delete — spec §49).
- [ ] **Phase 3 — Multi-item challan creation, supplier raw-material
      accounting, supplier pending engine.** Wire up `createChallan`
      callable (challan number via `generateChallanNumber`, initial
      lace/blouse auto-fill = saree qty per §6, per-item required/supplied/
      pending fields). Build the challan creation form (multi-item, editable
      lace/blouse). Complete `recordSupplierDelivery` UI.
- [ ] **Phase 4 — Stitching user ledger, finished-product returns, user FIFO
      engine.** Build admin "record production return" flow and stitching
      user's own pending views, calling `allocateStitchingReturnFIFO`
      through a new `recordManualReturn` callable (must share the engine
      with Phase 5's approval flow — spec §19).
- [ ] **Phase 5 — Deposit requests: submit / approve / reject, manual return,
      duplicate-request protection.** `approveDepositRequest` and
      `checkDuplicateDepositRequest` callables already exist — build the
      screens: stitching user's "create deposit request", admin's request
      review list with the blocking duplicate-warning dialog (§18/§52).
- [ ] **Phase 6 — Notifications (FCM + in-app).** Trigger notification docs
      from the Phase 3-5 callables (challan created, delivery received,
      deposit submitted/approved/rejected, supplier pending alert); build
      the in-app notification list + FCM token registration.
- [ ] **Phase 7 — Dashboards, pending views, ledgers, reports.** Admin
      dashboard totals, the two separate Pending Material views (Stitching
      vs Supplier, §29), supplier/stitching ledger screens with filters,
      and server-aggregated (not client-loaded) reports (§44).
- [ ] **Phase 8 — Security Rules hardening, indexes, audit logs UI.**
      Tighten `firestore.rules` per-collection scoping as denormalized join
      keys land; add remaining composite indexes as query patterns solidify;
      build the admin audit log viewer.
- [ ] **Phase 9 — Unit/integration/concurrency tests, performance.** Extend
      `functions/test/` with integration tests against the Firestore
      emulator (concurrent approve + manual return race, §41); Flutter
      widget tests for the ledger screens; load-test pagination.

## Mandatory test cases (spec §55) — current coverage

Covered today in `functions/test/stitchingFifo.test.ts` /
`supplierFifo.test.ts`: tests 3, 4, 6, 7, 8 (pure FIFO math). Tests 1, 2, 5,
9, 10 require the Firestore-emulator-backed callable functions built in
Phases 3–5 — add them as integration tests once those phases land.

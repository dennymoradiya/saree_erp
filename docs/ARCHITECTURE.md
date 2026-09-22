# Architecture

Section numbers below refer to the same numbering as the original business
spec, so future prompts can say "re-read §12" and it's unambiguous.

## 1. Two independent ledgers, one shared key

Every `challan_items/{id}` document holds fields for BOTH:

- **Engine B — SupplierMaterialLedger**: `{material}RequiredQuantity`,
  `{material}SuppliedQuantity`, `{material}PendingSupplierQuantity` for
  `saree` / `lace` / `blouse` independently.
- **Engine A — StitchingProductionLedger**: `sareeIssuedQuantity`,
  `sareeReturnedQuantity`, `sareePendingQuantity`.

They share `challanId` + `productId` + `sku`, but a write to one NEVER
touches the other. Completing production (§20) does not zero out supplier
pending, and settling supplier pending does not touch production status.

## 2. Accounting identity

`productId + sku` is the only valid key for FIFO/pending lookups
(`variantKey` getter on `ProductSku`). Product **name** is a snapshot only —
never used for matching. Historical challan/transaction docs always store
`productNameSnapshot` / `skuSnapshot` / `colorNameSnapshot` (§49).

## 3. FIFO scopes (never widen or narrow these)

- Stitching FIFO (Engine A): `stitchingUserId + productId + sku`, oldest
  `challan_items.createdAt` first (§13).
- Supplier FIFO (Engine B): `supplierId + productId + sku + materialType`,
  run **once per material type** — never combine SAREE/LACE/BLOUSE (§9, §10).

Both engines are pure functions in `functions/src/engines/` with no
Firestore I/O, so they're unit tested directly (`functions/test/`). The
callable functions in `functions/src/callable/` do the Firestore
read-allocate-write inside a single transaction (concurrency safety, §41).

## 4. Ledger, not counters

`challan_items` fields are a **denormalized cache**. The source of truth is
the immutable transaction collections:

- `material_transactions` — one row per stitching issue/return/adjustment.
- `supplier_material_transactions` — one row per supplier delivery
  allocation (can be split into an `OLD_PENDING_CHALLAN` row and a
  `NEW_CHALLAN` row from a single physical delivery, linked by
  `deliveryBatchId`).

Never "fix" a balance by editing a `challan_items` field directly — always
create a transaction and derive the new balance from it.

## 5. Deposit request vs official return

Submitting a `deposit_requests` doc (§15) must NOT touch `challan_items`.
Only `approveDepositRequest` (Cloud Function) re-reads live pending, runs
Engine A, writes the official `RETURN_APPROVED` transactions, and updates
balances — inside one transaction. Rejecting changes nothing but the
request's own status (§16).

## 6. Duplicate-entry protection (§18, §52)

Before an admin's manual return is recorded, the client MUST call
`checkDuplicateDepositRequest`. If it returns a match, block the manual
entry and force the admin to resolve the existing request first. Admin
direct returns and user-approved returns MUST call the exact same
allocation engine (`allocateStitchingReturnFIFO`) — spec §19 explicitly
forbids separate accounting logic for the two paths.

## 7. Security model (§40)

Firestore Security Rules (`firestore.rules`) deny ALL client writes to
`challans`, `challan_items`, `material_transactions`,
`supplier_material_transactions`, and `audit_logs`. Every accounting
mutation is a Cloud Functions callable using the Admin SDK. Reads are scoped
per role (admin sees everything; a supplier/stitching user sees only their
own linked records via `users/{uid}.supplierId` / `.stitchingUserId`).

## 8. Flutter layering

```
UI (ConsumerWidget)
  -> Controller / Notifier (Riverpod)
    -> Repository (abstract interface in features/*/domain)
      -> Data source (Firebase implementation in features/*/data)
```

No Firestore/Functions/Auth import ever appears inside a `presentation/`
file. See `features/auth/` as the reference implementation.

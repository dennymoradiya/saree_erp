# products feature

Phase 2 — Product + SKU/color management. Accounting key is productId+sku (variantKey), never product name. See lib/features/products/domain/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

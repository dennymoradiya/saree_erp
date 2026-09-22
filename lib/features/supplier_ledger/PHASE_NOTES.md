# supplier_ledger feature

Phase 7 — Supplier-facing and admin-facing ledger screens: totals, date/product/SKU filters, drill into pending challans. Reads supplier_material_transactions + challan_items.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

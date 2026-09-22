# stitching_ledger feature

Phase 4/7 — Stitching-user-facing and admin-facing ledger: issued/returned/pending per challan, FIFO breakdown. Reads material_transactions + challan_items.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

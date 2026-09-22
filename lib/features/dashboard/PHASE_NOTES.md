# dashboard feature

Phase 7 — Admin/Stitching/Supplier dashboards (totals, separate Stitching Pending vs Supplier Pending sections). Placeholder screens already exist under presentation/screens.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

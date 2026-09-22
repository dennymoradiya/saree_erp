# reports feature

Phase 7 — Paginated, server-aggregated reports (user-wise, supplier-wise, date-wise). Do not compute aggregates by loading all documents client-side (spec section 44).

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

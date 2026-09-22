# challans feature

Phase 3/4 — Multi-item challan creation UI, challan list/detail, cancellation with audit trail. Domain models already exist under domain/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

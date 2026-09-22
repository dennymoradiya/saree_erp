# audit_logs feature

Phase 8 — Admin-only audit log viewer over audit_logs collection. Domain model exists under domain/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

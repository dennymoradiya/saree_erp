# transactions feature

Phase 4-7 — Read-only transaction history views over material_transactions and supplier_material_transactions. Domain models exist under domain/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

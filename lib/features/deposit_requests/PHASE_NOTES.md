# deposit_requests feature

Phase 5 — Submit request (stitching user), review/approve/reject (admin), duplicate-request warning before manual return. Domain model exists under domain/. Backend logic lives in functions/src/callable/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

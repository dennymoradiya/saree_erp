# notifications feature

Phase 6 — FCM registration + in-app notification list/badge. Domain model exists under domain/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

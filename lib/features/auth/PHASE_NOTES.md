# auth feature

Phase 1 (DONE in this scaffold) — Firebase Authentication + Firestore role lookup, login screen, Riverpod controller. See domain/, data/, presentation/.

Architecture: UI -> Controller (Riverpod Notifier) -> Repository (interface in domain/) -> Firebase data source (data/). Never call Firestore/Functions directly from a widget.

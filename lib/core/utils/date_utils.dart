import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// All persistence MUST use Firestore [Timestamp]/UTC. These helpers are for
/// *display* formatting only — never store formatted date strings as the
/// source of truth for sorting or filtering (see docs/ARCHITECTURE.md §51).
abstract class AppDateUtils {
  static final DateFormat _displayDate = DateFormat('dd MMM yyyy');
  static final DateFormat _displayDateTime = DateFormat('dd MMM yyyy, hh:mm a');

  static String formatDate(Timestamp ts) => _displayDate.format(ts.toDate().toLocal());

  static String formatDateTime(Timestamp ts) =>
      _displayDateTime.format(ts.toDate().toLocal());

  /// Start-of-business-day boundary (local time) used for "today" duplicate
  /// deposit-request checks (§18, §52).
  static DateTime startOfToday() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

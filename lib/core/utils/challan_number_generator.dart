import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';

/// Atomically generates the next human-readable challan number for the given
/// calendar year, e.g. `CH-2026-000001`.
/// Must run inside a Firestore transaction alongside the challan write.
class ChallanNumberGenerator {
  const ChallanNumberGenerator._();

  static Future<String> generateNextNumber({
    required Transaction transaction,
    required FirebaseFirestore firestore,
    int? year,
  }) async {
    final targetYear = year ?? DateTime.now().year;
    final counterRef = firestore
        .collection(FirestorePaths.counters)
        .doc('${FirestorePaths.challanNumberCounter}_$targetYear');

    final counterSnap = await transaction.get(counterRef);
    final currentSeq =
        counterSnap.exists ? (counterSnap.data()?['value'] as num? ?? 0).toInt() : 0;
    final nextSeq = currentSeq + 1;

    transaction.set(
      counterRef,
      {'value': nextSeq},
      SetOptions(merge: true),
    );

    final paddedSeq = nextSeq.toString().padLeft(6, '0');
    return 'CH-$targetYear-$paddedSeq';
  }
}

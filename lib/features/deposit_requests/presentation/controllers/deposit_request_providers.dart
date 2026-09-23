import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/features/deposit_requests/data/firebase_deposit_request_repository.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request_repository.dart';

final depositRequestRepositoryProvider =
    Provider<DepositRequestRepository>((ref) {
  return FirebaseDepositRequestRepository();
});

class DepositRequestFilter {
  const DepositRequestFilter({
    this.stitchingUserId,
    this.status,
  });

  final String? stitchingUserId;
  final DepositRequestStatus? status;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DepositRequestFilter &&
          runtimeType == other.runtimeType &&
          stitchingUserId == other.stitchingUserId &&
          status == other.status;

  @override
  int get hashCode => Object.hash(stitchingUserId, status);
}

final depositRequestsStreamProvider =
    StreamProvider.family<List<DepositRequest>, DepositRequestFilter>(
        (ref, filter) {
  final repo = ref.watch(depositRequestRepositoryProvider);
  return repo.watchDepositRequests(
    stitchingUserId: filter.stitchingUserId,
    status: filter.status,
  );
});

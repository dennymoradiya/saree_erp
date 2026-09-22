import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';

abstract interface class DepositRequestRepository {
  Stream<List<DepositRequest>> watchDepositRequests({
    String? stitchingUserId,
    DepositRequestStatus? status,
  });

  Future<Result<DepositRequest>> submitDepositRequest({
    required String stitchingUserId,
    required List<DepositRequestItem> items,
    String? notes,
  });

  Future<Result<void>> approveDepositRequest(String requestId);

  Future<Result<void>> rejectDepositRequest({
    required String requestId,
    required String reason,
  });

  Future<Result<bool>> hasSameDayPendingDepositRequest({
    required String stitchingUserId,
    required String productId,
    required String sku,
  });

  Future<Result<List<String>>> recordManualAdminReturn({
    required String stitchingUserId,
    required String productId,
    required String sku,
    required double returnQuantity,
    String? notes,
  });
}

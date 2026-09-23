import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/engines/stitching_fifo.dart';
import 'package:saree_sutra/core/enums/audit_action.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/enums/transaction_type.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request_repository.dart';

class FirebaseDepositRequestRepository implements DepositRequestRepository {
  FirebaseDepositRequestRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Stream<List<DepositRequest>> watchDepositRequests({
    String? stitchingUserId,
    DepositRequestStatus? status,
  }) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.depositRequests)
        .orderBy('submittedAt', descending: true);

    if (stitchingUserId != null) {
      query = query.where('stitchingUserId', isEqualTo: stitchingUserId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return DepositRequest.fromJson({'requestId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Future<Result<DepositRequest>> submitDepositRequest({
    required String stitchingUserId,
    required List<DepositRequestItem> items,
    String? notes,
  }) async {
    try {
      final ref = _firestore.collection(FirestorePaths.depositRequests).doc();
      final now = FieldValue.serverTimestamp();
      final nowDt = DateTime.now();

      final request = DepositRequest(
        requestId: ref.id,
        stitchingUserId: stitchingUserId,
        status: DepositRequestStatus.pending,
        items: items,
        notes: notes?.trim(),
        submittedAt: nowDt,
      );

      final docData = {
        'requestId': ref.id,
        'stitchingUserId': stitchingUserId,
        'status': DepositRequestStatus.pending.value,
        'items': items
            .map(
              (i) => {
                'productId': i.productId,
                'sku': i.sku,
                'requestedQuantity': i.requestedQuantity,
              },
            )
            .toList(),
        'notes': notes?.trim(),
        'submittedAt': now,
        'reviewedAt': null,
        'reviewedBy': null,
        'rejectionReason': null,
        'resultingTransactionIds': null,
      };

      await ref.set(docData);
      return Success(request);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<bool>> hasSameDayPendingDepositRequest({
    required String stitchingUserId,
    required String productId,
    required String sku,
  }) async {
    try {
      final now = DateTime.now();
      final startOfToday = DateTime(now.year, now.month, now.day);

      final snap = await _firestore
          .collection(FirestorePaths.depositRequests)
          .where('stitchingUserId', isEqualTo: stitchingUserId)
          .where('status', isEqualTo: DepositRequestStatus.pending.value)
          .where('submittedAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfToday))
          .get();

      final hasMatch = snap.docs.any((d) {
        final items = d.data()['items'] as List<dynamic>? ?? [];
        return items.any(
          (item) =>
              item is Map &&
              item['productId'] == productId &&
              item['sku'] == sku,
        );
      });

      return Success(hasMatch);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> approveDepositRequest(String requestId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    try {
      final requestRef =
          _firestore.collection(FirestorePaths.depositRequests).doc(requestId);

      final reqDoc = await requestRef.get();
      if (!reqDoc.exists) {
        return const Failure(NotFoundException('Deposit request not found.'));
      }

      final requestData = reqDoc.data()!;
      if (requestData['status'] != DepositRequestStatus.pending.value) {
        return const Failure(
          DuplicateOperationException(
              'This deposit request is not in PENDING status.'),
        );
      }

      final stitchingUserId = requestData['stitchingUserId'] as String;
      final rawItems = requestData['items'] as List<dynamic>? ?? [];
      final items = rawItems
          .map((e) =>
              DepositRequestItem.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      final returnOps = await _prepareStitchingReturnOperations(
        stitchingUserId: stitchingUserId,
        returnDemands: items
            .map(
              (i) => _ReturnDemand(
                productId: i.productId,
                sku: i.sku,
                quantity: i.requestedQuantity,
              ),
            )
            .toList(),
        createdBy: currentUser.uid,
        depositRequestId: requestId,
      );

      await _firestore.runTransaction((tx) async {
        final now = FieldValue.serverTimestamp();

        // 1. ALL READS FIRST
        final requestSnap = await tx.get(requestRef);
        if (!requestSnap.exists) {
          throw const NotFoundException('Deposit request not found.');
        }

        // Lock all challan items and challan headers being modified
        for (final itemRef in returnOps.challanItemUpdates.keys) {
          await tx.get(itemRef);
        }
        for (final chRef in returnOps.challanHeaderUpdates.keys) {
          await tx.get(chRef);
        }

        // --- ALL READS COMPLETED. ALL WRITES FOLLOW ---

        // 2. Update challan items
        for (final entry in returnOps.challanItemUpdates.entries) {
          tx.update(entry.key, {
            ...entry.value,
            'updatedAt': now,
          });
        }

        // 3. Write material transactions
        for (final matTx in returnOps.materialTransactions) {
          final txRef = matTx['ref'] as DocumentReference<Map<String, dynamic>>;
          final data = matTx['data'] as Map<String, dynamic>;
          tx.set(txRef, {
            ...data,
            'createdAt': now,
          });
        }

        // 4. Update challan header statuses
        for (final entry in returnOps.challanHeaderUpdates.entries) {
          tx.update(entry.key, {
            ...entry.value,
            'updatedAt': now,
          });
        }

        // 5. Update deposit request status to APPROVED
        tx.update(requestRef, {
          'status': DepositRequestStatus.approved.value,
          'reviewedAt': now,
          'reviewedBy': currentUser.uid,
          'resultingTransactionIds': returnOps.createdTxIds,
        });

        // 6. Write audit log
        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': AuditAction.depositRequestApproved.value,
          'actorId': currentUser.uid,
          'actorRole': 'admin',
          'entityType': 'deposit_request',
          'entityId': requestId,
          'beforeData': {'status': DepositRequestStatus.pending.value},
          'afterData': {
            'status': DepositRequestStatus.approved.value,
            'resultingTransactionIds': returnOps.createdTxIds,
          },
          'createdAt': now,
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> rejectDepositRequest({
    required String requestId,
    required String reason,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    try {
      final requestRef =
          _firestore.collection(FirestorePaths.depositRequests).doc(requestId);
      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((tx) async {
        final requestSnap = await tx.get(requestRef);
        if (!requestSnap.exists) {
          throw const NotFoundException('Deposit request not found.');
        }
        final requestData = requestSnap.data()!;
        if (requestData['status'] != DepositRequestStatus.pending.value) {
          throw const DuplicateOperationException(
            'This deposit request is not in PENDING status.',
          );
        }

        tx.update(requestRef, {
          'status': DepositRequestStatus.rejected.value,
          'reviewedAt': now,
          'reviewedBy': currentUser.uid,
          'rejectionReason': reason.trim(),
        });

        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': AuditAction.depositRequestRejected.value,
          'actorId': currentUser.uid,
          'actorRole': 'admin',
          'entityType': 'deposit_request',
          'entityId': requestId,
          'beforeData': {'status': DepositRequestStatus.pending.value},
          'afterData': {
            'status': DepositRequestStatus.rejected.value,
            'reason': reason.trim(),
          },
          'createdAt': now,
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<List<String>>> recordManualAdminReturn({
    required String stitchingUserId,
    required String productId,
    required String sku,
    required double returnQuantity,
    String? notes,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    try {
      final returnOps = await _prepareStitchingReturnOperations(
        stitchingUserId: stitchingUserId,
        returnDemands: [
          _ReturnDemand(
            productId: productId,
            sku: sku,
            quantity: returnQuantity,
          ),
        ],
        createdBy: currentUser.uid,
        depositRequestId: null,
      );

      await _firestore.runTransaction((tx) async {
        final now = FieldValue.serverTimestamp();

        // 1. ALL READS FIRST
        for (final itemRef in returnOps.challanItemUpdates.keys) {
          await tx.get(itemRef);
        }
        for (final chRef in returnOps.challanHeaderUpdates.keys) {
          await tx.get(chRef);
        }

        // --- ALL READS COMPLETED. ALL WRITES FOLLOW ---

        // 2. Update challan items
        for (final entry in returnOps.challanItemUpdates.entries) {
          tx.update(entry.key, {
            ...entry.value,
            'updatedAt': now,
          });
        }

        // 3. Write material transactions
        for (final matTx in returnOps.materialTransactions) {
          final txRef = matTx['ref'] as DocumentReference<Map<String, dynamic>>;
          final data = matTx['data'] as Map<String, dynamic>;
          tx.set(txRef, {
            ...data,
            'createdAt': now,
          });
        }

        // 4. Update challan header statuses
        for (final entry in returnOps.challanHeaderUpdates.entries) {
          tx.update(entry.key, {
            ...entry.value,
            'updatedAt': now,
          });
        }

        // 5. Audit log
        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': AuditAction.manualReturnRecorded.value,
          'actorId': currentUser.uid,
          'actorRole': 'admin',
          'entityType': 'stitching_user',
          'entityId': stitchingUserId,
          'beforeData': null,
          'afterData': {
            'productId': productId,
            'sku': sku,
            'returnQuantity': returnQuantity,
            'resultingTransactionIds': returnOps.createdTxIds,
            'notes': notes?.trim(),
          },
          'createdAt': now,
        });
      });

      return Success(returnOps.createdTxIds);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  Future<_StitchingReturnOps> _prepareStitchingReturnOperations({
    required String stitchingUserId,
    required List<_ReturnDemand> returnDemands,
    required String createdBy,
    String? depositRequestId,
  }) async {
    // 1. Fetch user's active challans
    final userChallansSnap = await _firestore
        .collection(FirestorePaths.challans)
        .where('stitchingUserId', isEqualTo: stitchingUserId)
        .get();

    final activeChallans = userChallansSnap.docs
        .where((d) =>
            (d.data()['status'] as String?) != ChallanStatus.cancelled.value)
        .toList();

    final userChallanIds = activeChallans.map((d) => d.id).toSet();
    if (userChallanIds.isEmpty) {
      throw const LedgerViolationException(
        'This stitching unit has no active or pending challans.',
      );
    }

    final challanItemUpdates =
        <DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>{};
    final materialTransactions = <Map<String, dynamic>>[];
    final createdTxIds = <String>[];
    final modifiedChallanIds = <String>{};

    // Tracking in-memory pending to prevent double-spending across items
    final inMemoryPending = <String, double>{};

    for (final demand in returnDemands) {
      // Query items by productId only (single-field query, zero composite indexes required)
      final itemsSnap = await _firestore
          .collection(FirestorePaths.challanItems)
          .where('productId', isEqualTo: demand.productId)
          .get();

      final eligibleDocs = itemsSnap.docs.where((doc) {
        final data = doc.data();
        final chId = data['challanId'] as String? ?? '';
        if (!userChallanIds.contains(chId)) return false;
        if (data['sku'] != demand.sku) return false;
        final curPending = inMemoryPending[doc.id] ??
            (data['sareePendingQuantity'] as num? ?? 0).toDouble();
        return curPending > 0;
      }).toList();

      final pendingItems = eligibleDocs.map((doc) {
        final data = doc.data();
        final pending = inMemoryPending[doc.id] ??
            (data['sareePendingQuantity'] as num? ?? 0).toDouble();
        final createdAtTs = data['createdAt'] as Timestamp?;
        final createdAtMillis = createdAtTs?.millisecondsSinceEpoch ?? 0;

        return StitchingPendingChallanItem(
          challanId: data['challanId'] as String? ?? '',
          challanItemId: doc.id,
          sareePendingQuantity: pending,
          createdAtMillis: createdAtMillis,
        );
      }).toList();

      final allocations = allocateStitchingReturnFIFO(
        pendingItems: pendingItems,
        returnedFinishedQuantity: demand.quantity,
      );

      for (final alloc in allocations) {
        final doc = eligibleDocs.firstWhere((d) => d.id == alloc.challanItemId);
        final currentData = doc.data();
        final currentReturned =
            (currentData['sareeReturnedQuantity'] as num? ?? 0).toDouble();
        final currentPending = inMemoryPending[alloc.challanItemId] ??
            (currentData['sareePendingQuantity'] as num? ?? 0).toDouble();

        final newReturned = currentReturned + alloc.allocatedQuantity;
        final newPending = max(0.0, currentPending - alloc.allocatedQuantity);
        inMemoryPending[alloc.challanItemId] = newPending;

        challanItemUpdates[doc.reference] = {
          'sareeReturnedQuantity': newReturned,
          'sareePendingQuantity': newPending,
          'stitchingReturnedQuantity': newReturned,
        };

        modifiedChallanIds.add(alloc.challanId);

        final txRef =
            _firestore.collection(FirestorePaths.materialTransactions).doc();
        materialTransactions.add({
          'ref': txRef,
          'data': {
            'transactionId': txRef.id,
            'stitchingUserId': stitchingUserId,
            'productId': demand.productId,
            'sku': demand.sku,
            'challanId': alloc.challanId,
            'challanItemId': alloc.challanItemId,
            'quantity': alloc.allocatedQuantity,
            'depositRequestId': depositRequestId,
            'type': TransactionType.stitchingReturn.value,
            'createdBy': createdBy,
            'createdByRole': 'admin',
          },
        });
        createdTxIds.add(txRef.id);
      }
    }

    // Determine challan header status updates
    final challanHeaderUpdates =
        <DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>{};

    for (final chId in modifiedChallanIds) {
      final chRef = _firestore.collection(FirestorePaths.challans).doc(chId);

      // Query all items for this challan
      final allItemsSnap = await _firestore
          .collection(FirestorePaths.challanItems)
          .where('challanId', isEqualTo: chId)
          .get();

      bool allComplete = true;
      for (final iDoc in allItemsSnap.docs) {
        final pending = inMemoryPending[iDoc.id] ??
            (iDoc.data()['sareePendingQuantity'] as num? ?? 0).toDouble();
        if (pending > 0) {
          allComplete = false;
          break;
        }
      }

      challanHeaderUpdates[chRef] = {
        'status': allComplete
            ? ChallanStatus.completed.value
            : ChallanStatus.partiallyCompleted.value,
      };
    }

    return _StitchingReturnOps(
      challanItemUpdates: challanItemUpdates,
      materialTransactions: materialTransactions,
      challanHeaderUpdates: challanHeaderUpdates,
      createdTxIds: createdTxIds,
    );
  }
}

class _ReturnDemand {
  const _ReturnDemand({
    required this.productId,
    required this.sku,
    required this.quantity,
  });

  final String productId;
  final String sku;
  final double quantity;
}

class _StitchingReturnOps {
  const _StitchingReturnOps({
    required this.challanItemUpdates,
    required this.materialTransactions,
    required this.challanHeaderUpdates,
    required this.createdTxIds,
  });

  final Map<DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>
      challanItemUpdates;
  final List<Map<String, dynamic>> materialTransactions;
  final Map<DocumentReference<Map<String, dynamic>>, Map<String, dynamic>>
      challanHeaderUpdates;
  final List<String> createdTxIds;
}

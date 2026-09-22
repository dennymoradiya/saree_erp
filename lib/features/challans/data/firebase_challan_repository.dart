import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:saree_sutra/core/constants/firestore_paths.dart';
import 'package:saree_sutra/core/engines/supplier_fifo.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/audit_action.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/errors/app_exception.dart';
import 'package:saree_sutra/core/utils/firestore_exception_mapper.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/domain/challan_repository.dart';
import 'package:saree_sutra/features/challans/domain/create_challan_input.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

class FirebaseChallanRepository implements ChallanRepository {
  FirebaseChallanRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Stream<List<Challan>> watchChallans({
    String? supplierId,
    String? stitchingUserId,
    ChallanStatus? status,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection(FirestorePaths.challans).orderBy('createdAt', descending: true);

    if (supplierId != null) {
      query = query.where('supplierId', isEqualTo: supplierId);
    }
    if (stitchingUserId != null) {
      query = query.where('stitchingUserId', isEqualTo: stitchingUserId);
    }
    if (status != null) {
      query = query.where('status', isEqualTo: status.value);
    }

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return Challan.fromJson({'challanId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Stream<Challan> watchChallan(String challanId) {
    return _firestore
        .collection(FirestorePaths.challans)
        .doc(challanId)
        .snapshots()
        .map((doc) {
      if (!doc.exists) {
        throw const NotFoundException('Challan not found.');
      }
      return Challan.fromJson({'challanId': doc.id, ...doc.data()!});
    });
  }

  @override
  Stream<List<ChallanItem>> watchChallanItems(String challanId) {
    return _firestore
        .collection(FirestorePaths.challanItems)
        .where('challanId', isEqualTo: challanId)
        .snapshots()
        .map((snap) {
      return snap.docs.map((doc) {
        return ChallanItem.fromJson({'challanItemId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Stream<List<SupplierMaterialTransaction>> watchSupplierTransactionsForChallan(
    String challanId,
  ) {
    return _firestore
        .collection(FirestorePaths.supplierMaterialTransactions)
        .where('challanId', isEqualTo: challanId)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((doc) {
        return SupplierMaterialTransaction.fromJson({
          'transactionId': doc.id,
          ...doc.data(),
        });
      }).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  @override
  Stream<List<MaterialTransaction>> watchProductionTransactionsForChallan(
    String challanId,
  ) {
    return _firestore
        .collection(FirestorePaths.materialTransactions)
        .where('challanId', isEqualTo: challanId)
        .snapshots()
        .map((snap) {
      final items = snap.docs.map((doc) {
        return MaterialTransaction.fromJson({
          'transactionId': doc.id,
          ...doc.data(),
        });
      }).toList();
      items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return items;
    });
  }

  @override
  Stream<List<ChallanItem>> watchPendingStitchingItems({String? stitchingUserId}) {
    Query<Map<String, dynamic>> query = _firestore
        .collection(FirestorePaths.challanItems)
        .where('sareePendingQuantity', isGreaterThan: 0);

    return query.snapshots().map((snap) {
      return snap.docs.map((doc) {
        return ChallanItem.fromJson({'challanItemId': doc.id, ...doc.data()});
      }).toList();
    });
  }

  @override
  Stream<List<ChallanItem>> watchPendingSupplierItems({String? supplierId}) {
    return _firestore.collection(FirestorePaths.challanItems).snapshots().map((snap) {
      return snap.docs
          .map((doc) => ChallanItem.fromJson({'challanItemId': doc.id, ...doc.data()}))
          .where((item) =>
              item.sareePendingSupplierQuantity > 0 ||
              item.lacePendingSupplierQuantity > 0 ||
              item.blousePendingSupplierQuantity > 0,)
          .toList();
    });
  }

  @override
  Future<Result<Challan>> createChallan(CreateChallanInput input) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    if (input.items.isEmpty) {
      return const Failure(UnknownAppException('At least one item is required in a challan.'));
    }

    try {
      final challanRef = _firestore.collection(FirestorePaths.challans).doc();
      final deliveryBatchId =
          _firestore.collection(FirestorePaths.supplierMaterialTransactions).doc().id;

      // STEP 1: Query existing challan items for each product OUTSIDE the transaction.
      // This prevents non-transactional collection queries inside the transaction
      // and guarantees that all transaction reads strictly precede all transaction writes.
      final productIds = input.items.map((it) => it.productId).toSet();
      final existingItemsByProduct = <String, List<DocumentSnapshot<Map<String, dynamic>>>>{};

      for (final pid in productIds) {
        final qSnap = await _firestore
            .collection(FirestorePaths.challanItems)
            .where('productId', isEqualTo: pid)
            .get();
        existingItemsByProduct[pid] = qSnap.docs;
      }

      // In-memory tracking of pending balances per item so multiple items
      // in the same challan don't allocate the same pending shortage.
      final itemPendingOverrides = <String, Map<String, double>>{};
      final oldDocUpdates = <String, _OldDocUpdate>{};
      final materialTransactions = <Map<String, dynamic>>[];
      final newChallanItemsData = <_NewChallanItemRecord>[];

      for (final itemInput in input.items) {
        final itemRef = _firestore.collection(FirestorePaths.challanItems).doc();
        final candidateDocs = existingItemsByProduct[itemInput.productId] ?? [];

        // Helper to settle a component via FIFO
        SupplierFifoCalculation settleComponent({
          required MaterialType materialType,
          required String pendingFieldName,
          required String suppliedFieldName,
          required double deliveredQuantity,
        }) {
          if (deliveredQuantity <= 0) {
            return const SupplierFifoCalculation(allocations: [], remainingForNewChallan: 0.0);
          }

          final eligibleDocs = candidateDocs.where((d) {
            final data = d.data() ?? {};
            if (data['sku'] != itemInput.sku) return false;
            final curPending = itemPendingOverrides[d.id]?[pendingFieldName] ??
                (data[pendingFieldName] as num? ?? 0).toDouble();
            return curPending > 0;
          }).toList();

          final pendingItems = eligibleDocs.map((doc) {
            final data = doc.data() ?? {};
            final curPending = itemPendingOverrides[doc.id]?[pendingFieldName] ??
                (data[pendingFieldName] as num? ?? 0).toDouble();
            final createdAtTs = data['createdAt'] as Timestamp?;
            final createdAtMillis = createdAtTs?.millisecondsSinceEpoch ?? 0;

            return SupplierPendingChallanItem(
              challanId: data['challanId'] as String? ?? '',
              challanItemId: doc.id,
              pendingQuantity: curPending,
              createdAtMillis: createdAtMillis,
            );
          }).toList();

          final calculation = allocateSupplierMaterialFIFO(
            pendingItems: pendingItems,
            suppliedQuantity: deliveredQuantity,
          );

          for (final alloc in calculation.allocations) {
            final oldDoc = eligibleDocs.firstWhere((d) => d.id == alloc.challanItemId);
            final oldData = oldDoc.data() ?? {};
            final currentSupplied = (oldData[suppliedFieldName] as num? ?? 0).toDouble();
            final currentPending = itemPendingOverrides[alloc.challanItemId]?[pendingFieldName] ??
                (oldData[pendingFieldName] as num? ?? 0).toDouble();

            final newSupplied = currentSupplied + alloc.allocatedQuantity;
            final newPending = max(0.0, currentPending - alloc.allocatedQuantity);

            itemPendingOverrides.putIfAbsent(alloc.challanItemId, () => {})[pendingFieldName] =
                newPending;

            final existingUpdate = oldDocUpdates[alloc.challanItemId];
            final fields = existingUpdate != null
                ? Map<String, dynamic>.from(existingUpdate.fields)
                : <String, dynamic>{};
            fields[suppliedFieldName] = newSupplied;
            fields[pendingFieldName] = newPending;

            oldDocUpdates[alloc.challanItemId] = _OldDocUpdate(
              ref: oldDoc.reference,
              fields: fields,
            );

            // OLD_PENDING_CHALLAN transaction
            final txRef = _firestore
                .collection(FirestorePaths.supplierMaterialTransactions)
                .doc();
            materialTransactions.add({
              'ref': txRef,
              'data': {
                'transactionId': txRef.id,
                'deliveryBatchId': deliveryBatchId,
                'supplierId': input.supplierId,
                'productId': itemInput.productId,
                'sku': itemInput.sku,
                'materialType': materialType.value,
                'quantity': alloc.allocatedQuantity,
                'challanId': alloc.challanId,
                'challanItemId': alloc.challanItemId,
                'allocationType': AllocationType.oldPendingChallan.value,
                'allocationReferenceId': alloc.challanItemId,
                'createdBy': currentUser.uid,
              },
            });
          }

          if (calculation.remainingForNewChallan > 0) {
            final txRef = _firestore
                .collection(FirestorePaths.supplierMaterialTransactions)
                .doc();
            materialTransactions.add({
              'ref': txRef,
              'data': {
                'transactionId': txRef.id,
                'deliveryBatchId': deliveryBatchId,
                'supplierId': input.supplierId,
                'productId': itemInput.productId,
                'sku': itemInput.sku,
                'materialType': materialType.value,
                'quantity': calculation.remainingForNewChallan,
                'challanId': challanRef.id,
                'challanItemId': itemRef.id,
                'allocationType': AllocationType.newChallan.value,
                'allocationReferenceId': null,
                'createdBy': currentUser.uid,
              },
            });
          }

          return calculation;
        }

        // Settle component A: SAREE
        final sareeAlloc = settleComponent(
          materialType: MaterialType.saree,
          pendingFieldName: 'sareePendingSupplierQuantity',
          suppliedFieldName: 'sareeSuppliedQuantity',
          deliveredQuantity: itemInput.sareeSuppliedQuantity,
        );

        // Settle component B: LACE
        final laceAlloc = itemInput.requiresLace
            ? settleComponent(
                materialType: MaterialType.lace,
                pendingFieldName: 'lacePendingSupplierQuantity',
                suppliedFieldName: 'laceSuppliedQuantity',
                deliveredQuantity: itemInput.laceSuppliedQuantity,
              )
            : const SupplierFifoCalculation(allocations: [], remainingForNewChallan: 0.0);

        // Settle component C: BLOUSE
        final blouseAlloc = itemInput.requiresBlouse
            ? settleComponent(
                materialType: MaterialType.blouse,
                pendingFieldName: 'blousePendingSupplierQuantity',
                suppliedFieldName: 'blouseSuppliedQuantity',
                deliveredQuantity: itemInput.blouseSuppliedQuantity,
              )
            : const SupplierFifoCalculation(allocations: [], remainingForNewChallan: 0.0);

        // Compute balances for new challan item
        final sareeRequired = itemInput.sareeRequired;
        final sareeSupplied = sareeAlloc.remainingForNewChallan;
        final sareePendingSupplier = max(0.0, sareeRequired - sareeSupplied);

        final laceRequired = itemInput.laceRequired;
        final laceSupplied = laceAlloc.remainingForNewChallan;
        final lacePendingSupplier = max(0.0, laceRequired - laceSupplied);

        final blouseRequired = itemInput.blouseRequired;
        final blouseSupplied = blouseAlloc.remainingForNewChallan;
        final blousePendingSupplier = max(0.0, blouseRequired - blouseSupplied);

        newChallanItemsData.add(
          _NewChallanItemRecord(
            itemRef: itemRef,
            data: {
              'challanItemId': itemRef.id,
              'challanId': challanRef.id,
              'productId': itemInput.productId,
              'sku': itemInput.sku,
              'productNameSnapshot': itemInput.productNameSnapshot,
              'skuSnapshot': itemInput.skuSnapshot,
              'colorNameSnapshot': itemInput.colorNameSnapshot,
              'sareeIssuedQuantity': itemInput.sareeIssuedQuantity,
              'sareeReturnedQuantity': 0.0,
              'sareePendingQuantity': itemInput.sareeIssuedQuantity,
              'laceRequiredQuantity': laceRequired,
              'laceSuppliedQuantity': laceSupplied,
              'lacePendingSupplierQuantity': lacePendingSupplier,
              'blouseRequiredQuantity': blouseRequired,
              'blouseSuppliedQuantity': blouseSupplied,
              'blousePendingSupplierQuantity': blousePendingSupplier,
              'sareeRequiredQuantity': sareeRequired,
              'sareeSuppliedQuantity': sareeSupplied,
              'sareePendingSupplierQuantity': sareePendingSupplier,
              'stitchingReturnedQuantity': 0.0,
            },
          ),
        );
      }

      Challan? createdChallan;

      // STEP 2: Execute atomic transaction.
      // Strict rule: ALL READS FIRST, ALL WRITES AFTER.
      await _firestore.runTransaction((tx) async {
        final now = FieldValue.serverTimestamp();
        final nowDt = DateTime.now();

        // 1. ALL READS FIRST
        final counterRef = _firestore
            .collection(FirestorePaths.counters)
            .doc('${FirestorePaths.challanNumberCounter}_${nowDt.year}');

        final counterSnap = await tx.get(counterRef);
        final currentSeq =
            counterSnap.exists ? (counterSnap.data()?['value'] as num? ?? 0).toInt() : 0;
        final nextSeq = currentSeq + 1;
        final paddedSeq = nextSeq.toString().padLeft(6, '0');
        final challanNumber = 'CH-${nowDt.year}-$paddedSeq';

        // Read all old items being updated to lock them in the transaction
        for (final oldUpdate in oldDocUpdates.values) {
          await tx.get(oldUpdate.ref);
        }

        // --- ALL READS FINISHED. ALL WRITES FOLLOW ---

        // 2. Increment atomic counter
        tx.set(
          counterRef,
          {'value': nextSeq},
          SetOptions(merge: true),
        );

        // 3. Update older challan items with allocated shortages
        for (final oldUpdate in oldDocUpdates.values) {
          tx.update(oldUpdate.ref, {
            ...oldUpdate.fields,
            'updatedAt': now,
          });
        }

        // 4. Record supplier material transactions
        for (final matTx in materialTransactions) {
          final txRef = matTx['ref'] as DocumentReference<Map<String, dynamic>>;
          final txData = matTx['data'] as Map<String, dynamic>;
          tx.set(txRef, {
            ...txData,
            'createdAt': now,
          });
        }

        // 5. Write new challan items
        for (final newItem in newChallanItemsData) {
          tx.set(newItem.itemRef, {
            ...newItem.data,
            'createdAt': now,
            'updatedAt': now,
          });
        }

        // 6. Write challan header
        tx.set(challanRef, {
          'challanId': challanRef.id,
          'challanNumber': challanNumber,
          'supplierId': input.supplierId,
          'stitchingUserId': input.stitchingUserId,
          'createdBy': currentUser.uid,
          'createdByRole': input.creatorRole,
          'status': ChallanStatus.issued.value,
          'issuedAt': now,
          'createdAt': now,
          'updatedAt': now,
          'notes': input.notes?.trim(),
        });

        // 7. Write audit log
        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': AuditAction.challanCreated.value,
          'actorId': currentUser.uid,
          'actorRole': input.creatorRole,
          'entityType': 'challan',
          'entityId': challanRef.id,
          'beforeData': null,
          'afterData': {
            'challanNumber': challanNumber,
            'supplierId': input.supplierId,
            'stitchingUserId': input.stitchingUserId,
            'itemCount': input.items.length,
          },
          'createdAt': now,
        });

        createdChallan = Challan(
          challanId: challanRef.id,
          challanNumber: challanNumber,
          supplierId: input.supplierId,
          stitchingUserId: input.stitchingUserId,
          createdBy: currentUser.uid,
          createdByRole: input.creatorRole,
          status: ChallanStatus.issued,
          issuedAt: nowDt,
          createdAt: nowDt,
          updatedAt: nowDt,
          notes: input.notes?.trim(),
        );
      });

      return Success(createdChallan!);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> cancelChallan({
    required String challanId,
    required String reason,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    try {
      final challanRef = _firestore.collection(FirestorePaths.challans).doc(challanId);
      final now = FieldValue.serverTimestamp();

      await _firestore.runTransaction((tx) async {
        final snap = await tx.get(challanRef);
        if (!snap.exists) {
          throw const NotFoundException('Challan not found.');
        }

        final currentStatus = snap.data()?['status'] as String?;
        if (currentStatus == ChallanStatus.completed.value) {
          throw const LedgerViolationException('Cannot cancel an already completed challan.');
        }
        if (currentStatus == ChallanStatus.cancelled.value) {
          throw const DuplicateOperationException('Challan is already cancelled.');
        }

        tx.update(challanRef, {
          'status': ChallanStatus.cancelled.value,
          'cancelledReason': reason.trim(),
          'cancelledBy': currentUser.uid,
          'cancelledAt': now,
          'updatedAt': now,
        });

        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': 'CHALLAN_CANCELLED',
          'actorId': currentUser.uid,
          'actorRole': 'admin',
          'entityType': 'challan',
          'entityId': challanId,
          'beforeData': {'status': currentStatus},
          'afterData': {'status': ChallanStatus.cancelled.value, 'reason': reason.trim()},
          'createdAt': now,
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }

  @override
  Future<Result<void>> fulfillSupplierMaterial({
    required String challanId,
    required String challanItemId,
    double sareeQuantity = 0,
    double laceQuantity = 0,
    double blouseQuantity = 0,
    String? notes,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return const Failure(PermissionDeniedException('Sign in required.'));
    }

    if (sareeQuantity <= 0 && laceQuantity <= 0 && blouseQuantity <= 0) {
      return const Failure(
        UnknownAppException('At least one component quantity must be greater than 0.'),
      );
    }

    try {
      final challanRef = _firestore.collection(FirestorePaths.challans).doc(challanId);
      final itemRef = _firestore.collection(FirestorePaths.challanItems).doc(challanItemId);
      final deliveryBatchId =
          _firestore.collection(FirestorePaths.supplierMaterialTransactions).doc().id;

      await _firestore.runTransaction((tx) async {
        final now = FieldValue.serverTimestamp();

        // 1. Reads first
        final challanSnap = await tx.get(challanRef);
        if (!challanSnap.exists) {
          throw const NotFoundException('Challan not found.');
        }

        final itemSnap = await tx.get(itemRef);
        if (!itemSnap.exists) {
          throw const NotFoundException('Challan item not found.');
        }

        final challanData = challanSnap.data()!;
        final itemData = itemSnap.data()!;

        if (challanData['status'] == ChallanStatus.cancelled.value) {
          throw const LedgerViolationException('Cannot supply materials for a cancelled challan.');
        }

        final curSareeSupplied = (itemData['sareeSuppliedQuantity'] as num? ?? 0).toDouble();
        final curSareePending = (itemData['sareePendingSupplierQuantity'] as num? ?? 0).toDouble();
        final curLaceSupplied = (itemData['laceSuppliedQuantity'] as num? ?? 0).toDouble();
        final curLacePending = (itemData['lacePendingSupplierQuantity'] as num? ?? 0).toDouble();
        final curBlouseSupplied = (itemData['blouseSuppliedQuantity'] as num? ?? 0).toDouble();
        final curBlousePending = (itemData['blousePendingSupplierQuantity'] as num? ?? 0).toDouble();

        if (sareeQuantity > curSareePending) {
          throw ArgumentError('Saree quantity ($sareeQuantity) exceeds pending balance ($curSareePending).');
        }
        if (laceQuantity > curLacePending) {
          throw ArgumentError('Lace quantity ($laceQuantity) exceeds pending balance ($curLacePending).');
        }
        if (blouseQuantity > curBlousePending) {
          throw ArgumentError('Blouse quantity ($blouseQuantity) exceeds pending balance ($curBlousePending).');
        }

        final newSareeSupplied = curSareeSupplied + sareeQuantity;
        final newSareePending = max(0.0, curSareePending - sareeQuantity);
        final newLaceSupplied = curLaceSupplied + laceQuantity;
        final newLacePending = max(0.0, curLacePending - laceQuantity);
        final newBlouseSupplied = curBlouseSupplied + blouseQuantity;
        final newBlousePending = max(0.0, curBlousePending - blouseQuantity);

        final supplierId = challanData['supplierId'] as String? ?? '';
        final productId = itemData['productId'] as String? ?? '';
        final sku = itemData['sku'] as String? ?? '';

        // 2. Writes follow
        tx.update(itemRef, {
          'sareeSuppliedQuantity': newSareeSupplied,
          'sareePendingSupplierQuantity': newSareePending,
          'laceSuppliedQuantity': newLaceSupplied,
          'lacePendingSupplierQuantity': newLacePending,
          'blouseSuppliedQuantity': newBlouseSupplied,
          'blousePendingSupplierQuantity': newBlousePending,
          'updatedAt': now,
        });

        // SupplierMaterialTransaction helper
        void recordTx(MaterialType type, double qty) {
          if (qty <= 0) return;
          final txRef = _firestore.collection(FirestorePaths.supplierMaterialTransactions).doc();
          tx.set(txRef, {
            'transactionId': txRef.id,
            'deliveryBatchId': deliveryBatchId,
            'supplierId': supplierId,
            'productId': productId,
            'sku': sku,
            'materialType': type.value,
            'quantity': qty,
            'challanId': challanId,
            'challanItemId': challanItemId,
            'allocationType': AllocationType.oldPendingChallan.value,
            'allocationReferenceId': challanItemId,
            'createdBy': currentUser.uid,
            'createdAt': now,
            if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
          });
        }

        recordTx(MaterialType.saree, sareeQuantity);
        recordTx(MaterialType.lace, laceQuantity);
        recordTx(MaterialType.blouse, blouseQuantity);

        // Audit log
        final auditRef = _firestore.collection(FirestorePaths.auditLogs).doc();
        tx.set(auditRef, {
          'logId': auditRef.id,
          'action': 'SUPPLIER_MATERIAL_FULFILLED',
          'actorId': currentUser.uid,
          'actorRole': 'supplier_or_admin',
          'entityType': 'challan_item',
          'entityId': challanItemId,
          'beforeData': {
            'sareePending': curSareePending,
            'lacePending': curLacePending,
            'blousePending': curBlousePending,
          },
          'afterData': {
            'sareeFulfilled': sareeQuantity,
            'laceFulfilled': laceQuantity,
            'blouseFulfilled': blouseQuantity,
            'sareePending': newSareePending,
            'lacePending': newLacePending,
            'blousePending': newBlousePending,
            'deliveryBatchId': deliveryBatchId,
          },
          'createdAt': now,
        });
      });

      return const Success(null);
    } catch (e) {
      return Failure(mapFirebaseError(e));
    }
  }
}

class _OldDocUpdate {
  const _OldDocUpdate({
    required this.ref,
    required this.fields,
  });

  final DocumentReference<Map<String, dynamic>> ref;
  final Map<String, dynamic> fields;
}

class _NewChallanItemRecord {
  const _NewChallanItemRecord({
    required this.itemRef,
    required this.data,
  });

  final DocumentReference<Map<String, dynamic>> itemRef;
  final Map<String, dynamic> data;
}


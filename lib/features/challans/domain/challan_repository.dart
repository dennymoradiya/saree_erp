import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/utils/result.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/domain/create_challan_input.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';

abstract interface class ChallanRepository {
  Stream<List<Challan>> watchChallans({
    String? supplierId,
    String? stitchingUserId,
    ChallanStatus? status,
  });

  Stream<Challan> watchChallan(String challanId);

  Stream<List<ChallanItem>> watchChallanItems(String challanId);

  Stream<List<SupplierMaterialTransaction>> watchSupplierTransactionsForChallan(
    String challanId,
  );

  Stream<List<MaterialTransaction>> watchProductionTransactionsForChallan(
    String challanId,
  );

  Future<Result<Challan>> createChallan(CreateChallanInput input);

  Future<Result<void>> fulfillSupplierMaterial({
    required String challanId,
    required String challanItemId,
    double sareeQuantity = 0,
    double laceQuantity = 0,
    double blouseQuantity = 0,
    String? notes,
  });

  Future<Result<void>> cancelChallan({
    required String challanId,
    required String reason,
  });

  Stream<List<ChallanItem>> watchPendingStitchingItems({
    String? stitchingUserId,
  });

  Stream<List<ChallanItem>> watchPendingSupplierItems({
    String? supplierId,
  });
}


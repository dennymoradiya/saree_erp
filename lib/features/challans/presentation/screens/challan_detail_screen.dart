import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/utils/image_upload_helper.dart';
import 'package:saree_sutra/core/utils/whatsapp_share_helper.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/core/widgets/product_color_dot.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/widgets/fulfill_supplier_material_dialog.dart';
import 'package:saree_sutra/core/utils/challan_pdf_generator.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';
import 'package:saree_sutra/features/transactions/domain/material_transaction.dart';
import 'package:saree_sutra/features/transactions/domain/supplier_material_transaction.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class ChallanDetailScreen extends ConsumerWidget {
  const ChallanDetailScreen({super.key, required this.challan});

  final Challan challan;

  void _showCancelDialog(
      BuildContext context, WidgetRef ref, Challan liveChallan) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Cancel Challan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to cancel this challan? This will create an audit record.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Cancellation Reason *',
                hintText: 'e.g. Wrong party selected, order cancelled',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Back'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final reason = reasonCtrl.text.trim();
              if (reason.isEmpty) return;
              Navigator.of(dialogCtx).pop();

              final repo = ref.read(challanRepositoryProvider);
              final result = await repo.cancelChallan(
                challanId: liveChallan.challanId,
                reason: reason,
              );

              result.when(
                success: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Challan cancelled successfully.'),
                    ),
                  );
                  Navigator.of(context).pop();
                },
                failure: (err) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error cancelling challan: ${err.message}'),
                    ),
                  );
                },
              );
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  void _showFulfillDialog(
      BuildContext context, Challan liveChallan, ChallanItem item) {
    showDialog(
      context: context,
      builder: (_) => FulfillSupplierMaterialDialog(
        challan: liveChallan,
        item: item,
      ),
    );
  }

  void _shareChallan(
    BuildContext context,
    WidgetRef ref,
    Challan liveChallan,
    List<ChallanItem> items,
  ) {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Challan items are loading, please try again in a moment.'),
        ),
      );
      return;
    }

    final suppliers = ref.read(suppliersListProvider).asData?.value ?? [];
    final stitchingUsers =
        ref.read(stitchingUsersListProvider).asData?.value ?? [];

    var supplierName = liveChallan.supplierId;
    for (final s in suppliers) {
      if (s.supplierId == liveChallan.supplierId) {
        supplierName = s.name;
        break;
      }
    }

    var stitchingUserName = liveChallan.stitchingUserId;
    String? stitchingUserPhone;
    for (final u in stitchingUsers) {
      if (u.stitchingUserId == liveChallan.stitchingUserId) {
        stitchingUserName = u.name;
        stitchingUserPhone = u.phone;
        break;
      }
    }

    final shareItems = items.map((item) {
      return ChallanItemShareData(
        productName: item.productNameSnapshot,
        sku: item.skuSnapshot,
        colorName: item.colorNameSnapshot,
        targetQuantity: item.sareeIssuedQuantity,
        sareeSupplied: item.sareeSuppliedQuantity,
        laceSupplied: item.laceSuppliedQuantity,
        blouseSupplied: item.blouseSuppliedQuantity,
        sareePending: item.sareePendingSupplierQuantity,
        lacePending: item.lacePendingSupplierQuantity,
        blousePending: item.blousePendingSupplierQuantity,
        requiresLace: item.laceRequiredQuantity > 0,
        requiresBlouse: item.blouseRequiredQuantity > 0,
      );
    }).toList();

    final message = WhatsAppShareHelper.formatChallanMessage(
      challanNumber: liveChallan.challanNumber,
      createdAt: liveChallan.createdAt,
      supplierName: supplierName,
      stitchingUserName: stitchingUserName,
      notes: liveChallan.notes,
      imageUrl: liveChallan.imageUrl,
      items: shareItems,
    );

    WhatsAppShareHelper.shareToWhatsApp(
      phoneNumber: stitchingUserPhone,
      message: message,
    );
  }

  void _showPdfOptions(
    BuildContext context,
    WidgetRef ref,
    Challan liveChallan,
    List<ChallanItem> items,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomSheetCtx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE3F2FD),
                    child: Icon(Icons.share, color: Colors.blue),
                  ),
                  title: const Text(
                    'Share / Download PDF',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Save to device, send via WhatsApp, Drive, or Email',
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _generateAndHandlePdf(
                      context,
                      ref,
                      liveChallan,
                      items,
                      isPrint: false,
                    );
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEDE7F6),
                    child: Icon(Icons.print, color: Colors.deepPurple),
                  ),
                  title: const Text(
                    'Print / Preview PDF',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Preview pages and print directly to a printer',
                  ),
                  onTap: () {
                    Navigator.pop(bottomSheetCtx);
                    _generateAndHandlePdf(
                      context,
                      ref,
                      liveChallan,
                      items,
                      isPrint: true,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _generateAndHandlePdf(
    BuildContext context,
    WidgetRef ref,
    Challan liveChallan,
    List<ChallanItem> items, {
    required bool isPrint,
  }) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 14),
            Text('Preparing Challan PDF...'),
          ],
        ),
        duration: Duration(seconds: 2),
      ),
    );

    List<ChallanItem> currentItems = items;
    if (currentItems.isEmpty) {
      try {
        currentItems = await ref
            .read(challanRepositoryProvider)
            .watchChallanItems(liveChallan.challanId)
            .first
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    final suppliers = ref.read(suppliersListProvider).asData?.value ?? [];
    final stitchingUsers =
        ref.read(stitchingUsersListProvider).asData?.value ?? [];

    var supplierName = liveChallan.supplierId;
    for (final s in suppliers) {
      if (s.supplierId == liveChallan.supplierId) {
        supplierName = s.name;
        break;
      }
    }

    var stitchingUserName = liveChallan.stitchingUserId;
    String? stitchingUserPhone;
    for (final u in stitchingUsers) {
      if (u.stitchingUserId == liveChallan.stitchingUserId) {
        stitchingUserName = u.name;
        stitchingUserPhone = u.phone;
        break;
      }
    }

    List<SupplierMaterialTransaction> supplierTx = ref
            .read(supplierTransactionsForChallanProvider(liveChallan.challanId))
            .asData
            ?.value ??
        [];
    if (supplierTx.isEmpty) {
      try {
        supplierTx = await ref
            .read(challanRepositoryProvider)
            .watchSupplierTransactionsForChallan(liveChallan.challanId)
            .first
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    List<MaterialTransaction> prodTx = ref
            .read(
                productionTransactionsForChallanProvider(liveChallan.challanId))
            .asData
            ?.value ??
        [];
    if (prodTx.isEmpty) {
      try {
        prodTx = await ref
            .read(challanRepositoryProvider)
            .watchProductionTransactionsForChallan(liveChallan.challanId)
            .first
            .timeout(const Duration(seconds: 2));
      } catch (_) {}
    }

    final params = ChallanPdfParams(
      challan: liveChallan,
      items: currentItems,
      supplierName: supplierName,
      stitchingUserName: stitchingUserName,
      stitchingUserPhone: stitchingUserPhone,
      supplierTransactions: supplierTx,
      productionTransactions: prodTx,
    );

    if (!context.mounted) return;

    if (isPrint) {
      await ChallanPdfGenerator.previewOrPrintPdf(context, params);
    } else {
      await ChallanPdfGenerator.downloadOrSharePdf(context, params);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveChallan =
        ref.watch(challanStreamProvider(challan.challanId)).asData?.value ??
            challan;
    final itemsAsync =
        ref.watch(challanItemsStreamProvider(liveChallan.challanId));
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(liveChallan.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text(liveChallan.challanNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            tooltip: 'Download / Share PDF',
            onPressed: () => _showPdfOptions(
              context,
              ref,
              liveChallan,
              itemsAsync.asData?.value ?? [],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xFF25D366)),
            tooltip: 'Share on WhatsApp',
            onPressed: () => _shareChallan(
              context,
              ref,
              liveChallan,
              itemsAsync.asData?.value ?? [],
            ),
          ),
          if (liveChallan.status != ChallanStatus.completed &&
              liveChallan.status != ChallanStatus.cancelled)
            IconButton(
              icon: const Icon(Icons.cancel_outlined, color: Colors.red),
              tooltip: 'Cancel Challan',
              onPressed: () => _showCancelDialog(context, ref, liveChallan),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          liveChallan.challanNumber,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Chip(
                          label: Text(
                            liveChallan.status.displayName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Date: $dateStr'),
                    if (liveChallan.notes != null &&
                        liveChallan.notes!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text('Notes: ${liveChallan.notes!}'),
                    ],
                    if (liveChallan.cancelledReason != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Cancelled Reason: ${liveChallan.cancelledReason}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red.shade700,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _showPdfOptions(
                            context,
                            ref,
                            liveChallan,
                            itemsAsync.asData?.value ?? [],
                          ),
                          icon: const Icon(Icons.picture_as_pdf, size: 18),
                          label: const Text('Download / Print PDF'),
                        ),
                        FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF25D366),
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () => _shareChallan(
                            context,
                            ref,
                            liveChallan,
                            itemsAsync.asData?.value ?? [],
                          ),
                          icon: const Icon(Icons.share, size: 18),
                          label: const Text('Share on WhatsApp'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ChallanImageCard(challan: liveChallan),
            const SizedBox(height: 20),

            Text(
              'Challan Items & Accounting Details',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            itemsAsync.when(
              loading: () => const LoadingView(message: 'Loading items...'),
              error: (err, _) => ErrorView(message: err.toString()),
              data: (items) {
                if (items.isEmpty) {
                  return const Text('No items recorded for this challan.');
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final canFulfill =
                        liveChallan.status != ChallanStatus.cancelled;
                    return _ChallanItemDetailCard(
                      item: item,
                      index: index,
                      canFulfill: canFulfill,
                      onFulfill: () =>
                          _showFulfillDialog(context, liveChallan, item),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),

            // Dimension C: Transaction & Delivery History Timeline
            _ChallanTransactionHistorySection(
              challanId: liveChallan.challanId,
              challanItems: itemsAsync.asData?.value,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _ChallanItemDetailCard extends StatelessWidget {
  const _ChallanItemDetailCard({
    required this.item,
    required this.index,
    required this.canFulfill,
    required this.onFulfill,
  });

  final ChallanItem item;
  final int index;
  final bool canFulfill;
  final VoidCallback onFulfill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasPendingShortage = item.sareePendingSupplierQuantity > 0 ||
        item.lacePendingSupplierQuantity > 0 ||
        item.blousePendingSupplierQuantity > 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ProductColorDot(
                  colorName: item.colorNameSnapshot,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${item.productNameSnapshot} — ${item.colorNameSnapshot ?? ''} (${item.skuSnapshot})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Dimension A: Stitching Production State
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checkroom, size: 16, color: Colors.blue),
                      const SizedBox(width: 6),
                      Text(
                        'A. PRODUCTION (Finished)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatColumn(
                        label: 'Issued',
                        value: item.sareeIssuedQuantity.toInt().toString(),
                        color: Colors.black87,
                      ),
                      _StatColumn(
                        label: 'Returned',
                        value: item.sareeReturnedQuantity.toInt().toString(),
                        color: Colors.green.shade700,
                      ),
                      _StatColumn(
                        label: 'Pending Production',
                        value: item.sareePendingQuantity.toInt().toString(),
                        color: item.sareePendingQuantity > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Dimension B: Supplier Material State
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        'B. SUPPLIER RAW-MATERIAL STATE (Components)',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Colors.brown.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Table(
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1.2),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(1.5),
                    },
                    children: [
                      const TableRow(
                        children: [
                          Text('Component',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              )),
                          Text('Req.',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              )),
                          Text('Supplied',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              )),
                          Text('Supplier Shortage',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              )),
                        ],
                      ),
                      _buildMaterialTableRow(
                        'Saree',
                        item.sareeRequiredQuantity,
                        item.sareeSuppliedQuantity,
                        item.sareePendingSupplierQuantity,
                      ),
                      if (item.laceRequiredQuantity > 0)
                        _buildMaterialTableRow(
                          'Lace Pieces',
                          item.laceRequiredQuantity,
                          item.laceSuppliedQuantity,
                          item.lacePendingSupplierQuantity,
                        ),
                      if (item.blouseRequiredQuantity > 0)
                        _buildMaterialTableRow(
                          'Blouse Pieces',
                          item.blouseRequiredQuantity,
                          item.blouseSuppliedQuantity,
                          item.blousePendingSupplierQuantity,
                        ),
                    ],
                  ),

                  // Fulfill shortage action button
                  if (hasPendingShortage && canFulfill) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.amber.shade800,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.add_shopping_cart, size: 18),
                        label: const Text(
                          'Supply Remaining Material (Fulfill Shortage)',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: onFulfill,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildMaterialTableRow(
    String name,
    double req,
    double supplied,
    double pending,
  ) {
    final isReq = req > 0;
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            name,
            style: TextStyle(
              fontSize: 12,
              color: isReq ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            isReq ? req.toInt().toString() : '-',
            style: TextStyle(
              fontSize: 12,
              color: isReq ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            isReq ? supplied.toInt().toString() : '-',
            style: TextStyle(
              fontSize: 12,
              color: isReq ? Colors.black87 : Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            !isReq
                ? '-'
                : (pending > 0 ? '${pending.toInt()} PENDING' : '0 (OK)'),
            style: TextStyle(
              fontSize: 12,
              fontWeight: pending > 0 ? FontWeight.bold : FontWeight.normal,
              color: pending > 0 ? Colors.deepOrange : Colors.green,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}

/// Helper model to represent a group of material deliveries in one delivery batch.
class _DeliveryBatchGroup {
  _DeliveryBatchGroup({
    required this.batchId,
    required this.createdAt,
    required this.allocationType,
    required this.createdBy,
    required this.notes,
  });

  final String batchId;
  final DateTime createdAt;
  final AllocationType allocationType;
  final String createdBy;
  final String? notes;
  final List<SupplierMaterialTransaction> items = [];
}

/// Section displaying the full transaction history with exact date and time.
class _ChallanTransactionHistorySection extends ConsumerWidget {
  const _ChallanTransactionHistorySection({
    required this.challanId,
    this.challanItems,
  });

  final String challanId;
  final List<ChallanItem>? challanItems;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final supplierTxAsync =
        ref.watch(supplierTransactionsForChallanProvider(challanId));
    final productionTxAsync =
        ref.watch(productionTransactionsForChallanProvider(challanId));
    final itemsAsync = ref.watch(challanItemsStreamProvider(challanId));
    final items = challanItems ?? itemsAsync.asData?.value ?? [];

    final Map<String, ChallanItem> itemMapById = {
      for (final it in items) it.challanItemId: it,
    };
    final Map<String, ChallanItem> itemMapBySku = {
      for (final it in items) it.sku: it,
    };

    ChallanItem? findItem(String challanItemId, String sku) {
      return itemMapById[challanItemId] ?? itemMapBySku[sku];
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.history, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  'Transaction & Delivery History',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              'Complete audit trail of all raw-material deliveries and finished saree returns with timestamp.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: Colors.grey.shade700),
            ),
            const Divider(height: 24),
            supplierTxAsync.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (err, _) => ErrorView(message: err.toString()),
              data: (supplierTransactions) {
                return productionTxAsync.when(
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (err, _) => ErrorView(message: err.toString()),
                  data: (productionTransactions) {
                    if (supplierTransactions.isEmpty &&
                        productionTransactions.isEmpty) {
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Icon(Icons.receipt_long_outlined,
                                size: 40, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'No Transactions Recorded Yet',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Group supplier material transactions by deliveryBatchId
                    final Map<String, _DeliveryBatchGroup> batchMap = {};
                    for (final tx in supplierTransactions) {
                      final group = batchMap.putIfAbsent(
                        tx.deliveryBatchId,
                        () => _DeliveryBatchGroup(
                          batchId: tx.deliveryBatchId,
                          createdAt: tx.createdAt,
                          allocationType: tx.allocationType,
                          createdBy: tx.createdBy,
                          notes: tx.notes,
                        ),
                      );
                      group.items.add(tx);
                    }

                    final batchList = batchMap.values.toList()
                      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Supplier Material Deliveries
                        if (batchList.isNotEmpty) ...[
                          Text(
                            'Material Deliveries (${batchList.length} events)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.brown,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: batchList.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final batch = batchList[index];
                              final isInitial = batch.allocationType ==
                                  AllocationType.newChallan;
                              final dateFormatted =
                                  DateFormat('dd MMM yyyy, hh:mm:ss a')
                                      .format(batch.createdAt);

                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isInitial
                                      ? Colors.blue.shade50
                                          .withValues(alpha: 0.4)
                                      : Colors.green.shade50
                                          .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: isInitial
                                        ? Colors.blue.shade200
                                        : Colors.green.shade300,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              isInitial
                                                  ? Icons.local_shipping
                                                  : Icons.check_circle,
                                              size: 18,
                                              color: isInitial
                                                  ? Colors.blue
                                                  : Colors.green.shade700,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              isInitial
                                                  ? 'Initial Material Delivery'
                                                  : 'Remaining Material Fulfillment',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: isInitial
                                                    ? Colors.blue.shade900
                                                    : Colors.green.shade900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: isInitial
                                                ? Colors.blue.shade100
                                                : Colors.green.shade100,
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            isInitial
                                                ? 'Initial Supply'
                                                : 'Fulfillment',
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: isInitial
                                                  ? Colors.blue.shade900
                                                  : Colors.green.shade900,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 14, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          dateFormatted,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade700,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Group transactions in this delivery batch by item / SKU
                                    Builder(
                                      builder: (context) {
                                        final Map<
                                                String,
                                                List<
                                                    SupplierMaterialTransaction>>
                                            itemGroups = {};
                                        for (final tx in batch.items) {
                                          final key =
                                              tx.challanItemId.isNotEmpty
                                                  ? tx.challanItemId
                                                  : tx.sku;
                                          itemGroups
                                              .putIfAbsent(key, () => [])
                                              .add(tx);
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children:
                                              itemGroups.entries.map((entry) {
                                            final groupTxs = entry.value;
                                            final firstTx = groupTxs.first;
                                            final challanItem = findItem(
                                              firstTx.challanItemId,
                                              firstTx.sku,
                                            );
                                            final productName = challanItem
                                                    ?.productNameSnapshot ??
                                                'Product';
                                            final colorName =
                                                challanItem?.colorNameSnapshot;
                                            final sku =
                                                challanItem?.skuSnapshot ??
                                                    firstTx.sku;

                                            return Container(
                                              margin:
                                                  const EdgeInsets.only(top: 8),
                                              padding: const EdgeInsets.all(10),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: isInitial
                                                      ? Colors.blue.shade100
                                                      : Colors.green.shade200,
                                                ),
                                              ),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .checkroom_outlined,
                                                        size: 15,
                                                        color: theme.colorScheme
                                                            .primary,
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Expanded(
                                                        child: Wrap(
                                                          crossAxisAlignment:
                                                              WrapCrossAlignment
                                                                  .center,
                                                          spacing: 6,
                                                          children: [
                                                            Text(
                                                              productName,
                                                              style:
                                                                  const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 13,
                                                              ),
                                                            ),
                                                            if (colorName !=
                                                                    null &&
                                                                colorName
                                                                    .isNotEmpty)
                                                              Container(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 1.5,
                                                                ),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .primaryContainer
                                                                      .withValues(
                                                                    alpha: 0.6,
                                                                  ),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                    4,
                                                                  ),
                                                                ),
                                                                child: Row(
                                                                  mainAxisSize:
                                                                      MainAxisSize
                                                                          .min,
                                                                  children: [
                                                                    ProductColorDot(
                                                                      colorName:
                                                                          colorName,
                                                                      size: 10,
                                                                    ),
                                                                    const SizedBox(
                                                                      width: 4,
                                                                    ),
                                                                    Text(
                                                                      colorName,
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            11,
                                                                        fontWeight:
                                                                            FontWeight.w600,
                                                                        color: theme
                                                                            .colorScheme
                                                                            .onPrimaryContainer,
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                          ],
                                                        ),
                                                      ),
                                                      if (sku.isNotEmpty)
                                                        Text(
                                                          sku,
                                                          style: TextStyle(
                                                            fontSize: 11,
                                                            color: Colors
                                                                .grey.shade600,
                                                            fontFamily:
                                                                'monospace',
                                                          ),
                                                        ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    children: groupTxs
                                                        .map(
                                                          (tx) =>
                                                              _buildMaterialDeliveryBadge(
                                                            tx,
                                                          ),
                                                        )
                                                        .toList(),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        );
                                      },
                                    ),
                                    if (batch.notes != null &&
                                        batch.notes!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Notes: ${batch.notes}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            },
                          ),
                        ],

                        // Production Returns (if any)
                        if (productionTransactions.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Text(
                            'Finished Production Returns (${productionTransactions.length} records)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: Colors.indigo,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: productionTransactions.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final ptx = productionTransactions[index];
                              final dateFormatted =
                                  DateFormat('dd MMM yyyy, hh:mm:ss a')
                                      .format(ptx.createdAt);
                              final pItem = findItem(
                                ptx.challanItemId,
                                ptx.sku,
                              );
                              final pProductName =
                                  pItem?.productNameSnapshot ?? 'Product';
                              final pColorName = pItem?.colorNameSnapshot;
                              final pSku = pItem?.skuSnapshot ?? ptx.sku;

                              return Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.purple.shade50
                                      .withValues(alpha: 0.4),
                                  borderRadius: BorderRadius.circular(8),
                                  border:
                                      Border.all(color: Colors.purple.shade200),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Icon(
                                                  Icons.assignment_turned_in,
                                                  size: 16,
                                                  color: Colors.purple),
                                              const SizedBox(width: 6),
                                              Expanded(
                                                child: Wrap(
                                                  crossAxisAlignment:
                                                      WrapCrossAlignment.center,
                                                  spacing: 6,
                                                  children: [
                                                    Text(
                                                      pProductName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    if (pColorName != null &&
                                                        pColorName.isNotEmpty)
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 5,
                                                          vertical: 1,
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors
                                                              .purple.shade100,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(4),
                                                        ),
                                                        child: Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            ProductColorDot(
                                                              colorName:
                                                                  pColorName,
                                                              size: 10,
                                                            ),
                                                            const SizedBox(
                                                              width: 4,
                                                            ),
                                                            Text(
                                                              pColorName,
                                                              style: TextStyle(
                                                                fontSize: 10,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .purple
                                                                    .shade900,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    Text(
                                                      '($pSku)',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: Colors
                                                            .grey.shade600,
                                                        fontFamily: 'monospace',
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            dateFormatted,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Chip(
                                      label: Text(
                                        '+${ptx.quantity.toInt()} Sarees Returned',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green.shade900,
                                        ),
                                      ),
                                      backgroundColor: Colors.green.shade100,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialDeliveryBadge(SupplierMaterialTransaction tx) {
    Color bg;
    Color fg;
    IconData icon;
    String label;

    final qtyStr = tx.quantity % 1 == 0
        ? tx.quantity.toInt().toString()
        : tx.quantity.toString();

    switch (tx.materialType) {
      case MaterialType.saree:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        icon = Icons.layers_outlined;
        label = '$qtyStr Saree Fabric';
        break;
      case MaterialType.lace:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        icon = Icons.content_cut_outlined;
        label = '$qtyStr Lace Pieces';
        break;
      case MaterialType.blouse:
        bg = Colors.purple.shade100;
        fg = Colors.purple.shade900;
        icon = Icons.checkroom;
        label = '$qtyStr Blouse Pieces';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallanImageCard extends ConsumerStatefulWidget {
  const _ChallanImageCard({required this.challan});

  final Challan challan;

  @override
  ConsumerState<_ChallanImageCard> createState() => _ChallanImageCardState();
}

class _ChallanImageCardState extends ConsumerState<_ChallanImageCard> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final file = await ImageUploadHelper.pickImage(context);
    if (file == null) return;

    setState(() => _isUploading = true);

    try {
      final bytes = await file.readAsBytes();
      final downloadUrl = await ImageUploadHelper.uploadImage(
        bytes: bytes,
        storageFolder: 'challans',
        customFileName:
            '${widget.challan.challanId}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );

      final repo = ref.read(challanRepositoryProvider);
      final res = await repo.updateChallanImage(
        challanId: widget.challan.challanId,
        imageUrl: downloadUrl,
      );

      if (!mounted) return;

      res.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Challan image updated successfully.'),
              backgroundColor: Colors.green,
            ),
          );
        },
        failure: (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update challan image: ${err.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error uploading image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _confirmRemoveImage() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Image'),
        content: const Text(
          'Are you sure you want to remove the image attachment from this challan?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isUploading = true);

    try {
      final repo = ref.read(challanRepositoryProvider);
      final res = await repo.updateChallanImage(
        challanId: widget.challan.challanId,
        imageUrl: null,
      );

      if (!mounted) return;

      res.when(
        success: (_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Challan image removed.'),
            ),
          );
        },
        failure: (err) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove image: ${err.message}'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasImage =
        widget.challan.imageUrl != null && widget.challan.imageUrl!.isNotEmpty;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Challan Attachment / Photo',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (hasImage && !_isUploading)
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        tooltip: 'Change Photo',
                        onPressed: _pickAndUploadImage,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Remove Photo',
                        onPressed: _confirmRemoveImage,
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isUploading)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Uploading image...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            else if (hasImage)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      ImageUploadHelper.viewFullScreenImage(
                        context,
                        imageUrl: widget.challan.imageUrl!,
                        title: '${widget.challan.challanNumber} Attachment',
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          CachedNetworkImage(
                            imageUrl: widget.challan.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              height: 200,
                              color: Colors.grey.shade100,
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.broken_image,
                                      size: 40,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(height: 8),
                                    Text('Could not load image'),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.65),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.fullscreen,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Tap to zoom',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.fullscreen, size: 18),
                        label: const Text('View Full Screen'),
                        onPressed: () {
                          ImageUploadHelper.viewFullScreenImage(
                            context,
                            imageUrl: widget.challan.imageUrl!,
                            title: '${widget.challan.challanNumber} Attachment',
                          );
                        },
                      ),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Change Photo'),
                        onPressed: _pickAndUploadImage,
                      ),
                    ],
                  ),
                ],
              )
            else
              InkWell(
                onTap: _pickAndUploadImage,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade50,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        size: 32,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload Challan Image / Bill Photo',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Attach a physical challan photo, bill, or receipt (Camera / Gallery)',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/allocation_type.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_by_id_screen.dart';
import 'package:saree_sutra/features/supplier_ledger/domain/supplier_ledger_models.dart';
import 'package:saree_sutra/features/supplier_ledger/presentation/controllers/supplier_ledger_providers.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';

class SupplierLedgerScreen extends ConsumerStatefulWidget {
  const SupplierLedgerScreen({super.key, this.initialSupplierId});

  final String? initialSupplierId;

  @override
  ConsumerState<SupplierLedgerScreen> createState() => _SupplierLedgerScreenState();
}

class _SupplierLedgerScreenState extends ConsumerState<SupplierLedgerScreen> {
  late final String? _effectiveSupplierId;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authStateChangesProvider).value;
    final isAdmin = authUser?.role == UserRole.admin;
    if (authUser?.role == UserRole.supplier) {
      _effectiveSupplierId = authUser?.supplierId;
    } else {
      _effectiveSupplierId = widget.initialSupplierId;
    }

    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentFilter = ref.read(supplierLedgerFilterProvider(_effectiveSupplierId)).dateFilter;
        if (currentFilter == LedgerDateFilter.allTime) {
          ref.read(supplierLedgerFilterProvider(_effectiveSupplierId).notifier).setDateFilter(LedgerDateFilter.thisMonth);
        }
      });
    }
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final filterState = ref.read(supplierLedgerFilterProvider(_effectiveSupplierId));
    final initialRange = DateTimeRange(
      start: filterState.customStartDate ?? DateTime.now().subtract(const Duration(days: 7)),
      end: filterState.customEndDate ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      helpText: 'Select Custom Ledger Date Range',
    );

    if (picked != null) {
      ref.read(supplierLedgerFilterProvider(_effectiveSupplierId).notifier).setDateFilter(
            LedgerDateFilter.custom,
            customStart: picked.start,
            customEnd: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authStateChangesProvider).value;
    final isAdmin = authUser?.role == UserRole.admin;

    final filterState = ref.watch(supplierLedgerFilterProvider(_effectiveSupplierId));
    final filterNotifier = ref.read(supplierLedgerFilterProvider(_effectiveSupplierId).notifier);

    final ledgerAsync = ref.watch(dayWiseSupplierLedgerProvider(_effectiveSupplierId));
    final suppliersAsync = ref.watch(suppliersListProvider);
    final pendingSupplierItemsAsync =
        ref.watch(pendingSupplierItemsStreamProvider(_effectiveSupplierId));
    final suppliers = suppliersAsync.asData?.value ?? [];
    final pendingTotals = pendingSupplierItemsAsync.maybeWhen(
      data: (items) {
        var saree = 0.0;
        var lace = 0.0;
        var blouse = 0.0;

        for (final item in items) {
          saree += item.sareePendingSupplierQuantity;
          lace += item.lacePendingSupplierQuantity;
          blouse += item.blousePendingSupplierQuantity;
        }

        return {'saree': saree, 'lace': lace, 'blouse': blouse};
      },
      orElse: () => {'saree': 0.0, 'lace': 0.0, 'blouse': 0.0},
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Supplier Material Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Custom Date Range',
            onPressed: () => _selectCustomDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Supplier Selector Dropdown
                if (isAdmin) ...[
                  Row(
                    children: [
                      const Icon(Icons.business, size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: filterState.supplierId,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Supplier',
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Suppliers (Company Wide)'),
                            ),
                            ...suppliers.map((s) => DropdownMenuItem(
                                  value: s.supplierId,
                                  child: Text(s.name),
                                )),
                          ],
                          onChanged: (id) => filterNotifier.setSupplier(id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Date Presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LedgerDateFilter.availableFilters(isAdmin: isAdmin).map((preset) {
                      final isSelected = filterState.dateFilter == preset;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(preset.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (preset == LedgerDateFilter.custom) {
                              _selectCustomDateRange(context);
                            } else {
                              filterNotifier.setDateFilter(preset);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (filterState.dateFilter == LedgerDateFilter.custom &&
                    filterState.customStartDate != null &&
                    filterState.customEndDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Range: ${DateFormat('dd MMM yyyy').format(filterState.customStartDate!)} - ${DateFormat('dd MMM yyyy').format(filterState.customEndDate!)}',
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.primary),
                      ),
                      TextButton(
                        onPressed: () => _selectCustomDateRange(context),
                        child: const Text('Change', style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Ledger Content
          Expanded(
            child: ledgerAsync.when(
              loading: () => const LoadingView(message: 'Calculating ledger totals...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(dayWiseSupplierLedgerProvider(_effectiveSupplierId)),
              ),
              data: (dayWiseLedgers) {
                if (dayWiseLedgers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_stories_outlined, size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No Material Deliveries Found',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No transactions match the selected date & supplier filter.',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                // Overall Totals
                var overallSaree = 0.0;
                var overallLace = 0.0;
                var overallBlouse = 0.0;
                final allChallans = <String>{};

                for (final day in dayWiseLedgers) {
                  overallSaree += day.totalSaree;
                  overallLace += day.totalLace;
                  overallBlouse += day.totalBlouse;
                  for (final dist in day.distributions) {
                    allChallans.add(dist.challanId);
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Lace Pieces',
                            value: overallLace.toInt().toString(),
                            color: Colors.amber.shade800,
                            icon: Icons.line_style,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Blouse Pieces',
                            value: overallBlouse.toInt().toString(),
                            color: Colors.purple.shade700,
                            icon: Icons.dry_cleaning,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Saree Pieces',
                            value: overallSaree.toInt().toString(),
                            color: Colors.blue.shade700,
                            icon: Icons.checkroom,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Challans',
                            value: allChallans.length.toString(),
                            color: Colors.teal.shade700,
                            icon: Icons.receipt_long,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Day-Wise Material Deliveries',
                          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${dayWiseLedgers.length} Active Days',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Day-Wise Cards List
                    ...dayWiseLedgers.map((dayLedger) {
                      return _DayWiseSupplierCard(
                        dayLedger: dayLedger,
                        pendingTotals: pendingTotals,
                      );
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayWiseSupplierCard extends StatelessWidget {
  const _DayWiseSupplierCard({
    required this.dayLedger,
    required this.pendingTotals,
  });

  final DayWiseSupplierLedger dayLedger;
  final Map<String, double> pendingTotals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = dayLedger.date.year == now.year &&
        dayLedger.date.month == now.month &&
        dayLedger.date.day == now.day;
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(dayLedger.date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: isToday,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: isToday ? theme.colorScheme.primary : Colors.grey.shade200,
          foregroundColor: isToday ? Colors.white : Colors.black87,
          child: Text(
            '${dayLedger.date.day}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                dateStr,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              if (dayLedger.totalLace > 0)
                _ChipTag(
                  label: '${dayLedger.totalLace.toInt()} Lace',
                  color: Colors.amber.shade800,
                  bg: Colors.amber.shade50,
                ),
              if (dayLedger.totalBlouse > 0)
                _ChipTag(
                  label: '${dayLedger.totalBlouse.toInt()} Blouse',
                  color: Colors.purple.shade700,
                  bg: Colors.purple.shade50,
                ),
              if (dayLedger.totalSaree > 0)
                _ChipTag(
                  label: '${dayLedger.totalSaree.toInt()} Saree',
                  color: Colors.blue.shade700,
                  bg: Colors.blue.shade50,
                ),
              _ChipTag(
                label: '${dayLedger.uniqueChallansCount} Challan${dayLedger.uniqueChallansCount > 1 ? 's' : ''}',
                color: Colors.teal.shade800,
                bg: Colors.teal.shade50,
              ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Material Distribution (${dayLedger.distributions.length} events)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Text(
                      'Tap challan to view details',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Material summary table
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 18,
                      horizontalMargin: 8,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text('Material')),
                        DataColumn(label: Text('Completed')),
                        DataColumn(label: Text('Pending')),
                      ],
                      rows: [
                        _buildMaterialDataRow(
                          label: 'Lace',
                          completed: dayLedger.totalLace,
                          pending: pendingTotals['lace'] ?? 0,
                          color: Colors.amber.shade800,
                          completedColor: Colors.green.shade700,
                          pendingColor: Colors.orange.shade800,
                        ),
                        _buildMaterialDataRow(
                          label: 'Blouse',
                          completed: dayLedger.totalBlouse,
                          pending: pendingTotals['blouse'] ?? 0,
                          color: Colors.purple.shade700,
                          completedColor: Colors.green.shade700,
                          pendingColor: Colors.orange.shade800,
                        ),
                        _buildMaterialDataRow(
                          label: 'Saree',
                          completed: dayLedger.totalSaree,
                          pending: pendingTotals['saree'] ?? 0,
                          color: Colors.blue.shade700,
                          completedColor: Colors.green.shade700,
                          pendingColor: Colors.orange.shade800,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Product Breakdown',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 18,
                      horizontalMargin: 8,
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      columns: const [
                        DataColumn(label: Text('Product')),
                        DataColumn(label: Text('Material Qty')),
                        DataColumn(label: Text('Challan')),
                      ],
                      rows: () {
                        final productMap = <String, Map<String, dynamic>>{};
                        for (final dist in dayLedger.distributions) {
                          final productKey = '${dist.productName} (${dist.sku})';
                          final materialLabel = switch (dist.materialType) {
                            MaterialType.saree => 'Saree',
                            MaterialType.lace => 'Lace',
                            MaterialType.blouse => 'Blouse',
                          };

                          final entry = productMap.putIfAbsent(productKey, () => {
                                'challan': dist.challanNumber,
                                'materials': <String, double>{},
                              });
                          final materials = entry['materials'] as Map<String, double>;
                          materials[materialLabel] =
                              (materials[materialLabel] ?? 0.0) + dist.quantity;
                          entry['challan'] = dist.challanNumber;
                        }

                        return productMap.entries.map((entry) {
                          final materials = entry.value['materials'] as Map<String, double>;
                          final materialText = materials.entries
                              .map((item) => '${item.key}: ${item.value.toInt()}')
                              .join(' • ');

                          return DataRow(
                            cells: [
                              DataCell(Text(entry.key)),
                              DataCell(Text(materialText)),
                              DataCell(Text(entry.value['challan'] as String)),
                            ],
                          );
                        }).toList();
                      }(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Text(
                  'Challan activity (${dayLedger.distributions.length} entries)',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 8),

                ...dayLedger.distributions.take(3).map((dist) {
                  final timeStr = DateFormat('hh:mm a').format(dist.timestamp);
                  final isInitial = dist.allocationType == AllocationType.newChallan;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () => ChallanDetailByIdScreen.navigate(
                                  context,
                                  dist.challanId,
                                ),
                                child: Text(
                                  dist.challanNumber,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade900,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${dist.productName} (${dist.sku})',
                                style: const TextStyle(fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              timeStr,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isInitial
                                    ? Colors.blue.shade100
                                    : Colors.green.shade100,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isInitial ? 'Initial' : 'Fulfillment',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: isInitial
                                      ? Colors.blue.shade900
                                      : Colors.green.shade900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                if (dayLedger.distributions.length > 3)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '+${dayLedger.distributions.length - 3} more activity entries',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
             
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildMaterialDataRow({
    required String label,
    required double completed,
    required double pending,
    required Color color,
    required Color completedColor,
    required Color pendingColor,
  }) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 8),
              Text(label),
            ],
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: completedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${completed.toInt()} pcs',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: completedColor,
              ),
            ),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: pending > 0
                  ? pendingColor.withValues(alpha: 0.12)
                  : Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${pending.toInt()} pcs',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: pending > 0 ? pendingColor : Colors.green.shade700,
              ),
            ),
          ),
        ),
      ],
    );
  }

}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ChipTag extends StatelessWidget {
  const _ChipTag({
    required this.label,
    required this.color,
    required this.bg,
  });

  final String label;
  final Color color;
  final Color bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

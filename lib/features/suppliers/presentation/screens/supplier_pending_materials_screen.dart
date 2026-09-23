import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';
import 'package:saree_sutra/features/challans/presentation/widgets/fulfill_supplier_material_dialog.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

/// Dedicated screen displaying all pending raw materials that the supplier
/// has yet to provide, grouped by challan and item line.
class SupplierPendingMaterialsScreen extends ConsumerStatefulWidget {
  const SupplierPendingMaterialsScreen({
    super.key,
    required this.supplierId,
    this.initialMaterialType,
  });

  final String supplierId;
  final MaterialType? initialMaterialType;

  @override
  ConsumerState<SupplierPendingMaterialsScreen> createState() =>
      _SupplierPendingMaterialsScreenState();
}

class _SupplierPendingMaterialsScreenState
    extends ConsumerState<SupplierPendingMaterialsScreen> {
  late MaterialType? _selectedFilter;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialMaterialType;
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final challansFilter = ChallanFilter(supplierId: widget.supplierId);
    final challansAsync = ref.watch(challansStreamProvider(challansFilter));
    final pendingItemsAsync =
        ref.watch(pendingSupplierItemsStreamProvider(widget.supplierId));
    final stitchingUsersAsync = ref.watch(stitchingUsersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pending Materials to Provide',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            Text(
              'Items with remaining lace, blouse, or saree balances',
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
      body: challansAsync.when(
        loading: () => const LoadingView(message: 'Loading pending materials...'),
        error: (err, stack) => ErrorView(
          message: 'Failed to load challans: $err',
          onRetry: () => ref.invalidate(challansStreamProvider(challansFilter)),
        ),
        data: (challans) {
          final challansMap = <String, Challan>{
            for (final c in challans) c.challanId: c,
          };

          return pendingItemsAsync.when(
            loading: () =>
                const LoadingView(message: 'Loading shortage records...'),
            error: (err, stack) => ErrorView(
              message: 'Failed to load pending items: $err',
              onRetry: () => ref.invalidate(
                pendingSupplierItemsStreamProvider(widget.supplierId),
              ),
            ),
            data: (allItems) {
              // Only consider items that belong to this supplier's challans
              final supplierItems = allItems.where((item) {
                return challansMap.containsKey(item.challanId);
              }).toList();

              // Calculate aggregate pending totals
              var totalSaree = 0.0;
              var totalLace = 0.0;
              var totalBlouse = 0.0;
              for (final item in supplierItems) {
                totalSaree += item.sareePendingSupplierQuantity;
                totalLace += item.lacePendingSupplierQuantity;
                totalBlouse += item.blousePendingSupplierQuantity;
              }

              // Filter by selected material category
              var filteredItems = supplierItems.where((item) {
                if (_selectedFilter == MaterialType.lace) {
                  return item.lacePendingSupplierQuantity > 0;
                } else if (_selectedFilter == MaterialType.blouse) {
                  return item.blousePendingSupplierQuantity > 0;
                } else if (_selectedFilter == MaterialType.saree) {
                  return item.sareePendingSupplierQuantity > 0;
                }
                return item.sareePendingSupplierQuantity > 0 ||
                    item.lacePendingSupplierQuantity > 0 ||
                    item.blousePendingSupplierQuantity > 0;
              }).toList();

              // Filter by search query (Challan #, Product, SKU, Color)
              if (_searchQuery.isNotEmpty) {
                filteredItems = filteredItems.where((item) {
                  final challan = challansMap[item.challanId];
                  final chNum = challan?.challanNumber.toLowerCase() ?? '';
                  final pName = item.productNameSnapshot.toLowerCase();
                  final sku = item.skuSnapshot.toLowerCase();
                  final color = item.colorNameSnapshot?.toLowerCase() ?? '';
                  return chNum.contains(_searchQuery) ||
                      pName.contains(_searchQuery) ||
                      sku.contains(_searchQuery) ||
                      color.contains(_searchQuery);
                }).toList();
              }

              final stitchingUsers = stitchingUsersAsync.asData?.value ?? [];
              final stitchingUsersMap = {
                for (final u in stitchingUsers) u.stitchingUserId: u.name,
              };

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(challansStreamProvider(challansFilter));
                  ref.invalidate(
                    pendingSupplierItemsStreamProvider(widget.supplierId),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary KPI Cards Row
                    _buildSummaryRow(
                      context: context,
                      totalSaree: totalSaree.toInt(),
                      totalLace: totalLace.toInt(),
                      totalBlouse: totalBlouse.toInt(),
                      selectedFilter: _selectedFilter,
                      onFilterSelect: (type) {
                        setState(() {
                          _selectedFilter =
                              _selectedFilter == type ? null : type;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Search input
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by challan #, product, or SKU...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _searchController.clear(),
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Filter Chips Row
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          FilterChip(
                            label: Text('All (${supplierItems.length})'),
                            selected: _selectedFilter == null,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            avatar: const Icon(Icons.content_cut, size: 16),
                            label: Text('Lace (${totalLace.toInt()})'),
                            selected: _selectedFilter == MaterialType.lace,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter =
                                    _selectedFilter == MaterialType.lace
                                        ? null
                                        : MaterialType.lace;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            avatar: const Icon(Icons.checkroom, size: 16),
                            label: Text('Blouse (${totalBlouse.toInt()})'),
                            selected: _selectedFilter == MaterialType.blouse,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter =
                                    _selectedFilter == MaterialType.blouse
                                        ? null
                                        : MaterialType.blouse;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          FilterChip(
                            avatar: const Icon(Icons.layers, size: 16),
                            label: Text('Saree (${totalSaree.toInt()})'),
                            selected: _selectedFilter == MaterialType.saree,
                            onSelected: (_) {
                              setState(() {
                                _selectedFilter =
                                    _selectedFilter == MaterialType.saree
                                        ? null
                                        : MaterialType.saree;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // List count label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filteredItems.length} Pending Challan Line Item${filteredItems.length == 1 ? '' : 's'}',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (_selectedFilter != null || _searchQuery.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _selectedFilter = null;
                                _searchController.clear();
                              });
                            },
                            child: const Text('Reset Filters'),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Empty State or Item Cards
                    if (filteredItems.isEmpty)
                      _buildEmptyState(theme)
                    else
                      ...filteredItems.map((item) {
                        final challan = challansMap[item.challanId];
                        final stitchingName = challan != null
                            ? (stitchingUsersMap[challan.stitchingUserId] ??
                                challan.stitchingUserId)
                            : 'Unknown Unit';

                        return _PendingItemCard(
                          item: item,
                          challan: challan,
                          stitchingUnitName: stitchingName,
                          onFulfill: challan != null
                              ? () => _openFulfillDialog(context, challan, item)
                              : null,
                          onViewChallan: challan != null
                              ? () => Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          ChallanDetailScreen(challan: challan),
                                    ),
                                  )
                              : null,
                        );
                      }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openFulfillDialog(
    BuildContext context,
    Challan challan,
    ChallanItem item,
  ) {
    showDialog(
      context: context,
      builder: (_) => FulfillSupplierMaterialDialog(
        challan: challan,
        item: item,
      ),
    );
  }

  Widget _buildSummaryRow({
    required BuildContext context,
    required int totalSaree,
    required int totalLace,
    required int totalBlouse,
    required MaterialType? selectedFilter,
    required ValueChanged<MaterialType> onFilterSelect,
  }) {
    return Row(
      children: [
        Expanded(
          child: _ShortageSummaryCard(
            title: 'Lace Pending',
            count: totalLace,
            icon: Icons.content_cut,
            color: Colors.orange,
            isSelected: selectedFilter == MaterialType.lace,
            onTap: () => onFilterSelect(MaterialType.lace),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ShortageSummaryCard(
            title: 'Blouse Pending',
            count: totalBlouse,
            icon: Icons.checkroom,
            color: Colors.deepPurple,
            isSelected: selectedFilter == MaterialType.blouse,
            onTap: () => onFilterSelect(MaterialType.blouse),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ShortageSummaryCard(
            title: 'Saree Pending',
            count: totalSaree,
            icon: Icons.layers,
            color: Colors.teal,
            isSelected: selectedFilter == MaterialType.saree,
            onTap: () => onFilterSelect(MaterialType.saree),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    final hasActiveFilter =
        _selectedFilter != null || _searchQuery.isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(40),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: hasActiveFilter
                ? Colors.grey.shade200
                : Colors.green.shade100,
            child: Icon(
              hasActiveFilter ? Icons.search_off : Icons.check_circle_outline,
              size: 40,
              color: hasActiveFilter ? Colors.grey.shade600 : Colors.green,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasActiveFilter
                ? 'No matching pending materials'
                : 'All Raw Materials Supplied!',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            hasActiveFilter
                ? 'Try clearing the search or changing the filter type.'
                : 'There are currently no outstanding material shortages for your supply account.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ShortageSummaryCard extends StatelessWidget {
  const _ShortageSummaryCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final int count;
  final IconData icon;
  final MaterialColor color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPending = count > 0;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? color.shade100
              : (hasPending ? color.shade50 : Colors.grey.shade50),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? color.shade700
                : (hasPending ? color.shade300 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color.shade700),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isSelected ? color.shade900 : Colors.grey.shade800,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: hasPending ? color.shade900 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingItemCard extends StatelessWidget {
  const _PendingItemCard({
    required this.item,
    required this.challan,
    required this.stitchingUnitName,
    required this.onFulfill,
    required this.onViewChallan,
  });

  final ChallanItem item;
  final Challan? challan;
  final String stitchingUnitName;
  final VoidCallback? onFulfill;
  final VoidCallback? onViewChallan;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Challan number badge + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (challan != null)
                  InkWell(
                    onTap: onViewChallan,
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.receipt_long,
                            size: 15,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            challan!.challanNumber,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 11,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Text(
                    'Challan ID: ${item.challanId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                if (challan != null)
                  Text(
                    dateFormat.format(challan!.issuedAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Stitching unit recipient info
            Row(
              children: [
                Icon(Icons.storefront, size: 15, color: Colors.grey.shade600),
                const SizedBox(width: 6),
                Text(
                  'Stitching Unit: ',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Expanded(
                  child: Text(
                    stitchingUnitName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Product & SKU info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  radius: 18,
                  child: Icon(
                    Icons.inventory_2,
                    size: 18,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.productNameSnapshot,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              'SKU: ${item.skuSnapshot}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade800,
                              ),
                            ),
                          ),
                          if (item.colorNameSnapshot != null &&
                              item.colorNameSnapshot!.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.purple.shade50,
                                borderRadius: BorderRadius.circular(4),
                                border:
                                    Border.all(color: Colors.purple.shade200),
                              ),
                              child: Text(
                                item.colorNameSnapshot!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.purple.shade800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Material Pending Breakdown Table
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  if (item.laceRequiredQuantity > 0) ...[
                    _buildComponentRow(
                      component: 'Lace Material',
                      icon: Icons.content_cut,
                      requiredQty: item.laceRequiredQuantity,
                      suppliedQty: item.laceSuppliedQuantity,
                      pendingQty: item.lacePendingSupplierQuantity,
                      color: Colors.orange,
                    ),
                    const Divider(height: 1),
                  ],
                  if (item.blouseRequiredQuantity > 0) ...[
                    _buildComponentRow(
                      component: 'Blouse Material',
                      icon: Icons.checkroom,
                      requiredQty: item.blouseRequiredQuantity,
                      suppliedQty: item.blouseSuppliedQuantity,
                      pendingQty: item.blousePendingSupplierQuantity,
                      color: Colors.deepPurple,
                    ),
                    const Divider(height: 1),
                  ],
                  _buildComponentRow(
                    component: 'Saree Material',
                    icon: Icons.layers,
                    requiredQty: item.sareeRequiredQuantity,
                    suppliedQty: item.sareeSuppliedQuantity,
                    pendingQty: item.sareePendingSupplierQuantity,
                    color: Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onViewChallan != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onViewChallan,
                    icon: const Icon(Icons.description, size: 16),
                    label: const Text('View Challan'),
                  ),
                const SizedBox(width: 8),
                if (onFulfill != null)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: onFulfill,
                    icon: const Icon(Icons.add_shopping_cart, size: 16),
                    label: const Text('Supply Material'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentRow({
    required String component,
    required IconData icon,
    required double requiredQty,
    required double suppliedQty,
    required double pendingQty,
    required MaterialColor color,
  }) {
    final isPending = pendingQty > 0;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color.shade700),
          const SizedBox(width: 8),
          Expanded(
            flex: 3,
            child: Text(
              component,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Req: ${requiredQty.toInt()}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              'Sent: ${suppliedQty.toInt()}',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isPending ? color.shade100 : Colors.green.shade100,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: isPending ? color.shade300 : Colors.green.shade300,
              ),
            ),
            child: Text(
              isPending ? 'Pending: ${pendingQty.toInt()}' : 'Fulfilled',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isPending ? color.shade900 : Colors.green.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

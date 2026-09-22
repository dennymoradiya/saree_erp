import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class ChallanListScreen extends ConsumerStatefulWidget {
  const ChallanListScreen({super.key});

  @override
  ConsumerState<ChallanListScreen> createState() => _ChallanListScreenState();
}

class _ChallanListScreenState extends ConsumerState<ChallanListScreen> {
  ChallanStatus? _selectedStatus;
  String? _selectedSupplierId;
  String? _selectedStitchingUserId;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filter = ChallanFilter(
      supplierId: _selectedSupplierId,
      stitchingUserId: _selectedStitchingUserId,
      status: _selectedStatus,
    );
    final challansAsync = ref.watch(challansStreamProvider(filter));
    final suppliersAsync = ref.watch(suppliersListProvider);
    final stitchingUsersAsync = ref.watch(stitchingUsersListProvider);

    final suppliersMap = suppliersAsync.asData?.value.fold<Map<String, String>>(
          {},
          (map, s) => map..[s.supplierId] = s.name,
        ) ??
        {};

    final stitchingUsersMap = stitchingUsersAsync.asData?.value.fold<Map<String, String>>(
          {},
          (map, u) => map..[u.stitchingUserId] = u.name,
        ) ??
        {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challans'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Create Challan',
            onPressed: () => context.push(RoutePaths.adminCreateChallan),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Statuses'),
                  selected: _selectedStatus == null,
                  onSelected: (sel) => setState(() => _selectedStatus = null),
                ),
                const SizedBox(width: 8),
                ...ChallanStatus.values.map((status) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(status.displayName),
                      selected: _selectedStatus == status,
                      onSelected: (sel) =>
                          setState(() => _selectedStatus = sel ? status : null),
                    ),
                  );
                }),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search by Challan Number...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // List View
          Expanded(
            child: challansAsync.when(
              loading: () => const LoadingView(message: 'Loading challans...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(challansStreamProvider(filter)),
              ),
              data: (challans) {
                final filtered = challans.where((c) {
                  return c.challanNumber.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                if (challans.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        const Text('No Challans Found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        const Text('Create a new multi-item challan to start tracking production.'),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => context.push(RoutePaths.adminCreateChallan),
                          icon: const Icon(Icons.add),
                          label: const Text('Create Challan'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final challan = filtered[index];
                    final supplierName = suppliersMap[challan.supplierId] ?? challan.supplierId;
                    final stitchingUserName =
                        stitchingUsersMap[challan.stitchingUserId] ?? challan.stitchingUserId;

                    return _ChallanCard(
                      challan: challan,
                      supplierName: supplierName,
                      stitchingUserName: stitchingUserName,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RoutePaths.adminCreateChallan),
        icon: const Icon(Icons.add),
        label: const Text('New Challan'),
      ),
    );
  }
}

class _ChallanCard extends StatelessWidget {
  const _ChallanCard({
    required this.challan,
    required this.supplierName,
    required this.stitchingUserName,
  });

  final Challan challan;
  final String supplierName;
  final String stitchingUserName;

  Color _statusColor(ChallanStatus status, ThemeData theme) {
    switch (status) {
      case ChallanStatus.draft:
        return Colors.grey;
      case ChallanStatus.issued:
        return Colors.blue;
      case ChallanStatus.partiallyCompleted:
        return Colors.orange;
      case ChallanStatus.completed:
        return Colors.green;
      case ChallanStatus.cancelled:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(challan.status, theme);
    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(challan.createdAt);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChallanDetailScreen(challan: challan),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    challan.challanNumber,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      challan.status.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.business, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Supplier: ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  Text(supplierName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('Stitching User: ', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                  Text(stitchingUserName, style: const TextStyle(fontWeight: FontWeight.w600)),
                ],
              ),
              const Divider(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateStr,
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.outline),
                  ),
                  Row(
                    children: [
                      Text(
                        'View Items & Ledger',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 16, color: theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

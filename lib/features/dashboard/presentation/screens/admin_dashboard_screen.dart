import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/screens/deposit_requests_screen.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                ref.read(authControllerProvider.notifier).signOut();
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final productsAsync = ref.watch(productsStreamProvider);
    final suppliersAsync = ref.watch(suppliersListProvider);
    final stitchingUsersAsync = ref.watch(stitchingUsersListProvider);

    const pendingChallanFilter = ChallanFilter(status: ChallanStatus.issued);
    final activeChallansAsync =
        ref.watch(challansStreamProvider(pendingChallanFilter));

    const pendingRequestsFilter =
        DepositRequestFilter(status: DepositRequestStatus.pending);
    final depositRequestsAsync =
        ref.watch(depositRequestsStreamProvider(pendingRequestsFilter));

    final pendingStitchingItemsAsync =
        ref.watch(pendingStitchingItemsStreamProvider(null));
    final pendingSupplierItemsAsync =
        ref.watch(pendingSupplierItemsStreamProvider(null));

    final totalStitchingPending = pendingStitchingItemsAsync.maybeWhen(
      data: (items) =>
          items.fold<double>(0.0, (sum, i) => sum + i.sareePendingQuantity),
      orElse: () => 0.0,
    );

    final supplierPendingStats = pendingSupplierItemsAsync.maybeWhen(
      data: (items) {
        var saree = 0.0;
        var lace = 0.0;
        var blouse = 0.0;
        for (final i in items) {
          saree += i.sareePendingSupplierQuantity;
          lace += i.lacePendingSupplierQuantity;
          blouse += i.blousePendingSupplierQuantity;
        }
        return {'saree': saree, 'lace': lace, 'blouse': blouse};
      },
      orElse: () => {'saree': 0.0, 'lace': 0.0, 'blouse': 0.0},
    );

    final pendingRequestsCount = depositRequestsAsync.maybeWhen(
      data: (reqs) => reqs.length,
      orElse: () => 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operations Dashboard'),
        actions: [
          IconButton(
            icon: Badge(
              isLabelVisible: pendingRequestsCount > 0,
              label: Text('$pendingRequestsCount'),
              child: const Icon(Icons.assignment_turned_in_outlined),
            ),
            tooltip: 'Deposit / Return Requests',
            onPressed: () => context.push(RoutePaths.adminDepositRequests),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productsStreamProvider);
          ref.invalidate(suppliersListProvider);
          ref.invalidate(stitchingUsersListProvider);
          ref.invalidate(pendingStitchingItemsStreamProvider(null));
          ref.invalidate(pendingSupplierItemsStreamProvider(null));
          ref.invalidate(depositRequestsStreamProvider(pendingRequestsFilter));
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Requests Alert Banner
              if (pendingRequestsCount > 0) ...[
                Card(
                  color: Colors.amber.shade100,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.amber,
                      child:
                          Icon(Icons.notifications_active, color: Colors.white),
                    ),
                    title: Text(
                      '$pendingRequestsCount Return Request${pendingRequestsCount > 1 ? 's' : ''} Awaiting Approval',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Stitching units submitted finished sarees for return.',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () =>
                          context.push(RoutePaths.adminDepositRequests),
                      child: const Text('Review Now'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Primary Action Buttons
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () =>
                          context.push(RoutePaths.adminCreateChallan),
                      icon: const Icon(Icons.add_shopping_cart, size: 22),
                      label: const Text(
                        'Create Challan',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(56),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => showManualReturnDialog(context),
                      icon: const Icon(Icons.assignment_return_outlined, size: 22),
                      label: const Text(
                        'Manual Return',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () =>
                        context.push(RoutePaths.adminDepositRequests),
                    icon: const Icon(Icons.assignment_turned_in, size: 18),
                    label: Text(
                      pendingRequestsCount > 0
                          ? 'Deposit / Return ($pendingRequestsCount Pending)'
                          : 'Deposit / Return Sarees',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push(RoutePaths.adminChallans),
                    icon: const Icon(Icons.receipt_long, size: 18),
                    label: const Text(
                      'View All Challans',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.amber.shade100,
                      foregroundColor: Colors.brown.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push(RoutePaths.adminSupplierLedger),
                    icon: const Icon(Icons.inventory_2_outlined, size: 18),
                    label: const Text(
                      'Supplier Ledger',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green.shade100,
                      foregroundColor: Colors.green.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push(RoutePaths.adminStitchingLedger),
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text(
                      'Stitching Returns Ledger',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.purple.shade100,
                      foregroundColor: Colors.purple.shade900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () => context.push(RoutePaths.adminPendingReturnsLedger),
                    icon: const Icon(Icons.pending_actions_outlined, size: 18),
                    label: const Text(
                      'Pending Returns Ledger',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // KPI Cards
              Row(
                children: [
                  _KpiCard(
                    title: 'Products',
                    value: productsAsync.maybeWhen(
                      data: (d) => d.length.toString(),
                      orElse: () => '...',
                    ),
                    icon: Icons.checkroom,
                    color: Colors.purple,
                    onTap: () => context.push(RoutePaths.adminProducts),
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Suppliers',
                    value: suppliersAsync.maybeWhen(
                      data: (d) => d.length.toString(),
                      orElse: () => '...',
                    ),
                    icon: Icons.business,
                    color: Colors.blue,
                    onTap: () => context.push(RoutePaths.adminSuppliers),
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Stitching Units',
                    value: stitchingUsersAsync.maybeWhen(
                      data: (d) => d.length.toString(),
                      orElse: () => '...',
                    ),
                    icon: Icons.people,
                    color: Colors.teal,
                    onTap: () => context.push(RoutePaths.adminUsers),
                  ),
                  const SizedBox(width: 12),
                  _KpiCard(
                    title: 'Active Challans',
                    value: activeChallansAsync.maybeWhen(
                      data: (d) => d.length.toString(),
                      orElse: () => '...',
                    ),
                    icon: Icons.assignment,
                    color: Colors.orange,
                    onTap: () => context.push(RoutePaths.adminChallans),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // SECTION A: Stitching User Pending
              Card(
                elevation: 2,
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
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue.shade100,
                                child: const Icon(
                                  Icons.cut,
                                  size: 18,
                                  color: Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'A. PENDING (Finished)',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              TextButton.icon(
                                onPressed: () => context
                                    .push(RoutePaths.adminPendingReturnsLedger),
                                icon: const Icon(Icons.analytics_outlined,
                                    size: 16,),
                                label: const Text('View Ledger'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () =>
                                    context.push(RoutePaths.adminChallans),
                                child: const Text('View Challans'),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => context
                            .push(RoutePaths.adminPendingReturnsLedger),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Sarees Return:',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Tap to view user-wise & product-wise ledger',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${totalStitchingPending.toInt()} pic',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(Icons.arrow_forward_ios,
                                      size: 14, color: Colors.blue,),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // SECTION B: Supplier Raw-Material Shortages
              Card(
                elevation: 2,
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
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.amber.shade100,
                                child: const Icon(
                                  Icons.inventory_2,
                                  size: 18,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'B.MATERIAL SHORTAGES',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () =>
                                context.push(RoutePaths.adminSuppliers),
                            child: const Text('View'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _MaterialPendingStatBox(
                              label: 'Saree Pending',
                              value: supplierPendingStats['saree']!
                                  .toInt()
                                  .toString(),
                              icon: Icons.layers,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MaterialPendingStatBox(
                              label: 'Lace Pieces Pending',
                              value: supplierPendingStats['lace']!
                                  .toInt()
                                  .toString(),
                              icon: Icons.content_cut,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _MaterialPendingStatBox(
                              label: 'Blouse Pieces Pending',
                              value: supplierPendingStats['blouse']!
                                  .toInt()
                                  .toString(),
                              icon: Icons.checkroom,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Management Modules Grid
              Text(
                'Master Data & Operations Management',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ModuleNavCard(
                    title: 'Products & Colors (SKUs)',
                    subtitle: 'Manage saree catalogs & colors',
                    icon: Icons.checkroom_outlined,
                    onTap: () => context.push(RoutePaths.adminProducts),
                  ),
                  _ModuleNavCard(
                    title: 'Multi-Item Challans',
                    subtitle: 'Issue challans & FIFO settlement',
                    icon: Icons.receipt_long_outlined,
                    onTap: () => context.push(RoutePaths.adminChallans),
                  ),
                  _ModuleNavCard(
                    title: 'Suppliers Master',
                    subtitle: 'Manage raw material suppliers',
                    icon: Icons.business_outlined,
                    onTap: () => context.push(RoutePaths.adminSuppliers),
                  ),
                  _ModuleNavCard(
                    title: 'Stitching Units',
                    subtitle: 'Manage production unit logins',
                    icon: Icons.people_outline,
                    onTap: () => context.push(RoutePaths.adminUsers),
                  ),
                  _ModuleNavCard(
                    title: 'Deposit Requests',
                    subtitle: 'Review & approve returned sarees',
                    icon: Icons.assignment_turned_in_outlined,
                    onTap: () => context.push(RoutePaths.adminDepositRequests),
                  ),
                  _ModuleNavCard(
                    title: 'Create New Challan',
                    subtitle: 'New delivery & stitching issue',
                    icon: Icons.add_circle_outline,
                    onTap: () => context.push(RoutePaths.adminCreateChallan),
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: color.withValues(alpha: 0.15),
                  child: Icon(icon, size: 16, color: color),
                ),
                const SizedBox(height: 10),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MaterialPendingStatBox extends StatelessWidget {
  const _MaterialPendingStatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final isPending = (int.tryParse(value) ?? 0) > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isPending ? Colors.orange.shade50 : Colors.green.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPending ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: isPending ? Colors.orange : Colors.green,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isPending ? Colors.deepOrange : Colors.green.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleNavCard extends StatelessWidget {
  const _ModuleNavCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';

class SupplierDashboardScreen extends ConsumerWidget {
  const SupplierDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateChangesProvider).value;
    final supplierId = authUser?.supplierId;
    final theme = Theme.of(context);

    if (supplierId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Supplier Portal')),
        body: const Center(
          child: Text('Your account is not linked to a supplier profile.'),
        ),
      );
    }

    final filter = ChallanFilter(supplierId: supplierId);
    final challansAsync = ref.watch(challansStreamProvider(filter));
    final pendingSupplierItemsAsync =
        ref.watch(pendingSupplierItemsStreamProvider(supplierId));

    final pendingTotals = pendingSupplierItemsAsync.maybeWhen(
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

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authUser?.name ?? ''),
            const Text(
              'Raw Material Supplier Portal',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Action: Create Challan
            Card(
              elevation: 2,
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      radius: 24,
                      child: const Icon(Icons.local_shipping, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dispatch Material Challan',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Delivering lace, blouse, or base saree to stitching unit? Create a delivery challan.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () => context.push(RoutePaths.supplierCreateChallan),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Create Challan'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Material Ledger Quick Navigation
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade100,
                  foregroundColor: Colors.brown.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.push(RoutePaths.supplierLedger),
                icon: const Icon(Icons.auto_stories, size: 20),
                label: const Text(
                  'View Day-Wise Supply Ledger & Distributions',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Supplier Raw Material Shortage Overview
            Text(
              'My Raw Material Shortage / Pending Balances',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Saree Pending',
                    value: pendingTotals['saree']!.toInt().toString(),
                    icon: Icons.layers,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Lace Pending',
                    value: pendingTotals['lace']!.toInt().toString(),
                    icon: Icons.content_cut,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Blouse Pending',
                    value: pendingTotals['blouse']!.toInt().toString(),
                    icon: Icons.checkroom,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // My Delivery Challans
            Text(
              'My Supply Challans',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            challansAsync.when(
              loading: () =>
                  const LoadingView(message: 'Loading supply challans...'),
              error: (err, _) => Text('Error loading challans: $err'),
              data: (challans) {
                if (challans.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                          child: Text(
                              'No challans recorded for your supply account yet.',),),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: challans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final challan = challans[index];
                    return ListTile(
                      tileColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      leading: const CircleAvatar(child: Icon(Icons.inventory)),
                      title: Text(challan.challanNumber,
                          style: const TextStyle(fontWeight: FontWeight.bold),),
                      subtitle: Text(
                          'Issued: ${DateFormat('dd MMM yyyy').format(challan.createdAt)}',),
                      trailing: Chip(label: Text(challan.status.displayName)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ChallanDetailScreen(challan: challan),
                          ),
                        );
                      },
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
}

class _SupplierShortageCard extends StatelessWidget {
  const _SupplierShortageCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final pending = (int.tryParse(value) ?? 0) > 0;
    return Card(
      color: pending ? Colors.orange.shade50 : Colors.green.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: pending ? Colors.orange.shade200 : Colors.green.shade200,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon,
                    size: 16, color: pending ? Colors.orange : Colors.green,),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 11),
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
                color: pending ? Colors.deepOrange : Colors.green.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

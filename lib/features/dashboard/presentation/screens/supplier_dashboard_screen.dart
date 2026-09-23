import 'package:flutter/material.dart' hide MaterialType;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/material_type.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';
import 'package:saree_sutra/features/suppliers/presentation/screens/supplier_pending_materials_screen.dart';

class SupplierDashboardScreen extends ConsumerWidget {
  const SupplierDashboardScreen({super.key});

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
        final myChallans = challansAsync.asData?.value;
        final myChallanIds = myChallans != null
            ? {for (final c in myChallans) c.challanId}
            : null;

        var saree = 0.0;
        var lace = 0.0;
        var blouse = 0.0;
        for (final i in items) {
          if (myChallanIds != null && !myChallanIds.contains(i.challanId)) {
            continue;
          }
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
            onPressed: () => _showLogoutDialog(context, ref),
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
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      radius: 24,
                      child: const Icon(Icons.local_shipping,
                          color: Colors.white, size: 24),
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
                              color: theme.colorScheme.onPrimaryContainer
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: () =>
                          context.push(RoutePaths.supplierCreateChallan),
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
              height: 48,
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.amber.shade100,
                  foregroundColor: Colors.brown.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'My Raw Material Shortage / Pending Balances',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _openPendingMaterials(context, supplierId),
                  icon: const Icon(Icons.arrow_forward, size: 14),
                  label: const Text('View All', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Saree Pending',
                    value: pendingTotals['saree']!.toInt().toString(),
                    icon: Icons.layers,
                    onTap: () => _openPendingMaterials(
                      context,
                      supplierId,
                      initialType: MaterialType.saree,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Lace Pending',
                    value: pendingTotals['lace']!.toInt().toString(),
                    icon: Icons.content_cut,
                    onTap: () => _openPendingMaterials(
                      context,
                      supplierId,
                      initialType: MaterialType.lace,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SupplierShortageCard(
                    title: 'Blouse Pending',
                    value: pendingTotals['blouse']!.toInt().toString(),
                    icon: Icons.checkroom,
                    onTap: () => _openPendingMaterials(
                      context,
                      supplierId,
                      initialType: MaterialType.blouse,
                    ),
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
                          'No challans recorded for your supply account yet.',
                        ),
                      ),
                    ),
                  );
                }

                final pendingItems =
                    pendingSupplierItemsAsync.asData?.value ?? [];
                final pendingChallanIds =
                    pendingItems.map((it) => it.challanId).toSet();

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: challans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final challan = challans[index];
                    final hasPending =
                        pendingChallanIds.contains(challan.challanId);

                    // Compute pending breakdown for this challan if shortages exist
                    var pendingSaree = 0.0;
                    var pendingLace = 0.0;
                    var pendingBlouse = 0.0;
                    if (hasPending) {
                      for (final it in pendingItems) {
                        if (it.challanId == challan.challanId) {
                          pendingSaree += it.sareePendingSupplierQuantity;
                          pendingLace += it.lacePendingSupplierQuantity;
                          pendingBlouse += it.blousePendingSupplierQuantity;
                        }
                      }
                    }

                    final shortageParts = <String>[];
                    if (pendingSaree > 0) {
                      shortageParts.add('${pendingSaree.toInt()} Saree');
                    }
                    if (pendingLace > 0) {
                      shortageParts.add('${pendingLace.toInt()} Lace');
                    }
                    if (pendingBlouse > 0) {
                      shortageParts.add('${pendingBlouse.toInt()} Blouse');
                    }
                    final shortageText = shortageParts.join(', ');

                    return ListTile(
                      tileColor: hasPending
                          ? Colors.red.shade50.withValues(alpha: 0.15)
                          : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: hasPending
                              ? Colors.red.shade400
                              : Colors.grey.shade200,
                          width: hasPending ? 1.5 : 1.0,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: hasPending
                            ? Colors.red.shade100
                            : theme.colorScheme.primaryContainer,
                        child: Icon(
                          hasPending
                              ? Icons.warning_amber_rounded
                              : Icons.inventory,
                          color: hasPending
                              ? Colors.red.shade700
                              : theme.colorScheme.primary,
                        ),
                      ),
                      title: Row(
                        children: [
                          Expanded(
                            child: Text(
                              challan.challanNumber,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (hasPending) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Pending Shortage',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Issued: ${DateFormat('dd MMM yyyy').format(challan.createdAt)}',
                          ),
                          if (hasPending && shortageText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                'Pending: $shortageText',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: Chip(
                        label: Text(
                          challan.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasPending ? Colors.red.shade800 : null,
                          ),
                        ),
                        backgroundColor: hasPending ? Colors.red.shade50 : null,
                        side: hasPending
                            ? BorderSide(color: Colors.red.shade300)
                            : null,
                      ),
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

  void _openPendingMaterials(
    BuildContext context,
    String supplierId, {
    MaterialType? initialType,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SupplierPendingMaterialsScreen(
          supplierId: supplierId,
          initialMaterialType: initialType,
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
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final VoidCallback? onTap;

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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: 16,
                    color: pending ? Colors.orange : Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 11),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 9,
                      color: pending
                          ? Colors.orange.shade700
                          : Colors.green.shade700,
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
      ),
    );
  }
}

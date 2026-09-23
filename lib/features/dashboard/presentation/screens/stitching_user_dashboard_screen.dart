import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';

import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/widgets/create_deposit_request_dialog.dart';

class StitchingUserDashboardScreen extends ConsumerWidget {
  const StitchingUserDashboardScreen({super.key});

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
    final stitchingUserId = authUser?.stitchingUserId;
    final theme = Theme.of(context);

    if (stitchingUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manufacturer Portal')),
        body: const Center(
          child:
              Text('Your account is not linked to a stitching user profile.'),
        ),
      );
    }

    final challansFilter = ChallanFilter(stitchingUserId: stitchingUserId);
    final challansAsync = ref.watch(challansStreamProvider(challansFilter));

    final depositFilter =
        DepositRequestFilter(stitchingUserId: stitchingUserId);
    final depositRequestsAsync =
        ref.watch(depositRequestsStreamProvider(depositFilter));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(authUser?.name ?? ''),
            const Text(
              'Stitching Unit / Manufacturer Portal',
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
            // Action Banner
            Card(
              color: theme.colorScheme.primaryContainer,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.assignment_return,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Finished Saree Return',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                          Text(
                            'Ready to return stitched sarees? Submit a deposit request for verification.',
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
                    FilledButton(
                      onPressed: () => _showCreateDepositRequestDialog(
                          context, stitchingUserId),
                      child: const Text('Submit Return'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Pending Products Ledger Quick Navigation
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.purple.shade100,
                  foregroundColor: Colors.purple.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () =>
                    context.push(RoutePaths.stitchingPendingReturnsLedger),
                icon: const Icon(Icons.pending_actions_outlined, size: 20),
                label: const Text(
                  'View Pending Products to Return (Shortage Stock)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Production Returns Ledger Quick Navigation
            SizedBox(
              height: 48,
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => context.push(RoutePaths.stitchingLedger),
                icon: const Icon(Icons.fact_check_outlined, size: 20),
                label: const Text(
                  'View Day-Wise Returns Ledger & Challans',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // My Assigned Challans
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Assigned Challans (${DateFormat('MMMM yyyy').format(DateTime.now())})',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),

            challansAsync.when(
              loading: () => const LoadingView(message: 'Loading challans...'),
              error: (err, _) => Text('Error loading challans: $err'),
              data: (challans) {
                final now = DateTime.now();
                final currentMonthChallans = challans.where((c) {
                  return c.createdAt.year == now.year &&
                      c.createdAt.month == now.month;
                }).toList();

                if (currentMonthChallans.isEmpty) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No challans assigned for ${DateFormat('MMMM yyyy').format(now)}.',
                        ),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: currentMonthChallans.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final challan = currentMonthChallans[index];
                    final isCompleted =
                        challan.status == ChallanStatus.completed;

                    return ListTile(
                      tileColor: isCompleted
                          ? Colors.white
                          : Colors.red.shade50.withValues(alpha: 0.15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.grey.shade200
                              : Colors.red.shade400,
                          width: isCompleted ? 1.0 : 1.5,
                        ),
                      ),
                      leading: CircleAvatar(
                        backgroundColor: isCompleted
                            ? theme.colorScheme.primaryContainer
                            : Colors.red.shade100,
                        child: Icon(
                          isCompleted
                              ? Icons.receipt
                              : Icons.warning_amber_rounded,
                          color: isCompleted
                              ? theme.colorScheme.primary
                              : Colors.red.shade700,
                        ),
                      ),
                      title: Text(
                        challan.challanNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Issued: ${DateFormat('dd MMM yyyy').format(challan.createdAt)}',
                      ),
                      trailing: Chip(
                        label: Text(
                          challan.status.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isCompleted
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                        backgroundColor: isCompleted
                            ? Colors.green.shade50
                            : Colors.red.shade50,
                        side: BorderSide(
                          color: isCompleted
                              ? Colors.green.shade200
                              : Colors.red.shade300,
                        ),
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
            const SizedBox(height: 24),

            // My Deposit Requests
            Text(
              'My Submitted Return Requests',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            depositRequestsAsync.when(
              loading: () => const LoadingView(message: 'Loading requests...'),
              error: (err, _) => Text('Error: $err'),
              data: (requests) {
                if (requests.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                          child: Text('No return requests submitted yet.')),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final req = requests[index];
                    final dateStr = DateFormat('dd MMM yyyy, hh:mm a')
                        .format(req.submittedAt);

                    Color statusColor = Colors.grey;
                    if (req.status == DepositRequestStatus.approved)
                      statusColor = Colors.green;
                    if (req.status == DepositRequestStatus.pending)
                      statusColor = Colors.orange;
                    if (req.status == DepositRequestStatus.rejected)
                      statusColor = Colors.red;

                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dateStr,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                                Chip(
                                  backgroundColor:
                                      statusColor.withValues(alpha: 0.1),
                                  label: Text(
                                    req.status.displayName,
                                    style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...req.items.map((i) {
                              return Text(
                                '• ${i.requestedQuantity.toInt()} sarees (SKU: ${i.sku})',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              );
                            }),
                            if (req.rejectionReason != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Rejection note: ${req.rejectionReason!}',
                                style: const TextStyle(
                                    color: Colors.red, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
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

  void _showCreateDepositRequestDialog(
      BuildContext context, String stitchingUserId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          CreateDepositRequestDialog(stitchingUserId: stitchingUserId),
    );
  }
}

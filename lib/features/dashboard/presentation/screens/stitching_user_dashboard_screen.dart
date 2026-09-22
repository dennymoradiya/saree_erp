import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/routing/route_paths.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';

import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';

class StitchingUserDashboardScreen extends ConsumerWidget {
  const StitchingUserDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateChangesProvider).value;
    final stitchingUserId = authUser?.stitchingUserId;
    final theme = Theme.of(context);

    if (stitchingUserId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Manufacturer Portal')),
        body: const Center(
          child: Text('Your account is not linked to a stitching user profile.'),
        ),
      );
    }

    final challansFilter = ChallanFilter(stitchingUserId: stitchingUserId);
    final challansAsync = ref.watch(challansStreamProvider(challansFilter));

    final depositFilter = DepositRequestFilter(stitchingUserId: stitchingUserId);
    final depositRequestsAsync = ref.watch(depositRequestsStreamProvider(depositFilter));

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
            onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
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
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primary,
                      child: const Icon(Icons.assignment_return, color: Colors.white),
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
                              color: theme.colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _showCreateDepositRequestDialog(context, stitchingUserId),
                      child: const Text('Submit Return'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Production Returns Ledger Quick Navigation
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade100,
                  foregroundColor: Colors.green.shade900,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
            Text(
              'My Assigned Challans',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            challansAsync.when(
              loading: () => const LoadingView(message: 'Loading challans...'),
              error: (err, _) => Text('Error loading challans: $err'),
              data: (challans) {
                if (challans.isEmpty) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(child: Text('No challans assigned to your unit yet.')),
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
                      leading: const CircleAvatar(child: Icon(Icons.receipt)),
                      title: Text(challan.challanNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Issued: ${DateFormat('dd MMM yyyy').format(challan.createdAt)}'),
                      trailing: Chip(label: Text(challan.status.displayName)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ChallanDetailScreen(challan: challan),
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
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
                      child: Center(child: Text('No return requests submitted yet.')),
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
                    final dateStr = DateFormat('dd MMM yyyy, hh:mm a').format(req.submittedAt);

                    Color statusColor = Colors.grey;
                    if (req.status == DepositRequestStatus.approved) statusColor = Colors.green;
                    if (req.status == DepositRequestStatus.pending) statusColor = Colors.orange;
                    if (req.status == DepositRequestStatus.rejected) statusColor = Colors.red;

                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(dateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Chip(
                                  backgroundColor: statusColor.withValues(alpha: 0.1),
                                  label: Text(
                                    req.status.displayName,
                                    style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ...req.items.map((i) {
                              return Text(
                                '• ${i.requestedQuantity.toInt()} sarees (SKU: ${i.sku})',
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              );
                            }),
                            if (req.rejectionReason != null) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Rejection note: ${req.rejectionReason!}',
                                style: const TextStyle(color: Colors.red, fontSize: 12),
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

  void _showCreateDepositRequestDialog(BuildContext context, String stitchingUserId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _CreateDepositRequestDialog(stitchingUserId: stitchingUserId),
    );
  }
}

class _CreateDepositRequestDialog extends ConsumerStatefulWidget {
  const _CreateDepositRequestDialog({required this.stitchingUserId});

  final String stitchingUserId;

  @override
  ConsumerState<_CreateDepositRequestDialog> createState() => _CreateDepositRequestDialogState();
}

class _CreateDepositRequestDialogState extends ConsumerState<_CreateDepositRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Product? _selectedProduct;
  ProductSku? _selectedSku;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null || _selectedSku == null) {
      setState(() => _error = 'Please select Product and SKU.');
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) {
      setState(() => _error = 'Positive return quantity is required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(depositRequestRepositoryProvider);
    final result = await repo.submitDepositRequest(
      stitchingUserId: widget.stitchingUserId,
      items: [
        DepositRequestItem(
          productId: _selectedProduct!.productId,
          sku: _selectedSku!.sku,
          requestedQuantity: qty,
        ),
      ],
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deposit request submitted. Awaiting admin approval.')),
        );
      },
      failure: (err) {
        setState(() {
          _error = err.message;
          _isLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return AlertDialog(
      title: const Text('Submit Finished Saree Return'),
      content: SizedBox(
        width: 450,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.only(bottom: 12),
                    color: Colors.red.shade50,
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading products: $e'),
                  data: (products) {
                    final activeProducts = products.where((p) => p.isActive).toList();
                    return DropdownButtonFormField<Product>(
                      initialValue: _selectedProduct,
                      decoration: const InputDecoration(labelText: 'Product *'),
                      items: activeProducts.map((p) {
                        return DropdownMenuItem(value: p, child: Text('${p.name} (${p.productCode})'));
                      }).toList(),
                      onChanged: (p) => setState(() {
                        _selectedProduct = p;
                        _selectedSku = null;
                      }),
                      validator: (v) => v == null ? 'Product is required' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                if (_selectedProduct != null)
                  Consumer(
                    builder: (context, ref, _) {
                      final skusAsync = ref.watch(
                        productSkusStreamProvider(_selectedProduct!.productId),
                      );
                      return skusAsync.when(
                        loading: () => const LinearProgressIndicator(),
                        error: (e, _) => Text('Error: $e'),
                        data: (skus) {
                          final activeSkus = skus.where((s) => s.isActive).toList();
                          return DropdownButtonFormField<ProductSku>(
                            initialValue: _selectedSku,
                            decoration: const InputDecoration(labelText: 'Color SKU *'),
                            items: activeSkus.map((sku) {
                              return DropdownMenuItem(
                                value: sku,
                                child: Text('${sku.colorName} (${sku.sku})'),
                              );
                            }).toList(),
                            onChanged: (sku) => setState(() => _selectedSku = sku),
                            validator: (v) => v == null ? 'SKU is required' : null,
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _qtyCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Finished Sarees Returned *',
                    hintText: 'e.g. 80',
                  ),
                  validator: (v) =>
                      (double.tryParse(v ?? '') ?? 0) <= 0 ? 'Positive quantity required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(labelText: 'Notes / Remarks (Optional)'),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _submit,
          child: _isLoading
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Submit Request'),
        ),
      ],
    );
  }
}

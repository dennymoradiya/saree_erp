import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/users/domain/stitching_user_profile.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class DepositRequestsScreen extends ConsumerStatefulWidget {
  const DepositRequestsScreen({super.key});

  @override
  ConsumerState<DepositRequestsScreen> createState() =>
      _DepositRequestsScreenState();
}

class _DepositRequestsScreenState extends ConsumerState<DepositRequestsScreen> {
  DepositRequestStatus? _selectedStatus = DepositRequestStatus.pending;

  @override
  Widget build(BuildContext context) {
    final filter = DepositRequestFilter(status: _selectedStatus);
    final requestsAsync = ref.watch(depositRequestsStreamProvider(filter));
    final usersAsync = ref.watch(stitchingUsersListProvider);

    final usersMap = usersAsync.asData?.value.fold<Map<String, String>>(
          {},
          (map, u) => map..[u.stitchingUserId] = u.name,
        ) ??
        {};

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finished Production Deposit Requests'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Manual Return'),
            onPressed: () => _showManualReturnDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Status filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => setState(() => _selectedStatus = null),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Pending Approval'),
                  selected: _selectedStatus == DepositRequestStatus.pending,
                  onSelected: (sel) => setState(
                    () => _selectedStatus =
                        sel ? DepositRequestStatus.pending : null,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Approved'),
                  selected: _selectedStatus == DepositRequestStatus.approved,
                  onSelected: (sel) => setState(
                    () => _selectedStatus =
                        sel ? DepositRequestStatus.approved : null,
                  ),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Rejected'),
                  selected: _selectedStatus == DepositRequestStatus.rejected,
                  onSelected: (sel) => setState(
                    () => _selectedStatus =
                        sel ? DepositRequestStatus.rejected : null,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: requestsAsync.when(
              loading: () => const LoadingView(message: 'Loading requests...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () =>
                    ref.invalidate(depositRequestsStreamProvider(filter)),
              ),
              data: (requests) {
                if (requests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.assignment_turned_in_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'No Deposit Requests',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _selectedStatus == DepositRequestStatus.pending
                              ? 'There are no pending requests to review.'
                              : 'No requests match the selected filter.',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: requests.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final userName = usersMap[request.stitchingUserId] ??
                        request.stitchingUserId;

                    return _DepositRequestCard(
                      request: request,
                      userName: userName,
                      onApproved: () =>
                          ref.invalidate(depositRequestsStreamProvider(filter)),
                      onRejected: () =>
                          ref.invalidate(depositRequestsStreamProvider(filter)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showManualReturnDialog(BuildContext context) {
    showManualReturnDialog(context);
  }
}

Future<void> showManualReturnDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => const ManualReturnDialog(),
  );
}

class _DepositRequestCard extends ConsumerWidget {
  const _DepositRequestCard({
    required this.request,
    required this.userName,
    required this.onApproved,
    required this.onRejected,
  });

  final DepositRequest request;
  final String userName;
  final VoidCallback onApproved;
  final VoidCallback onRejected;

  Future<void> _approve(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Approve Production Return'),
        content: Text(
          'Approve return from $userName? This will run the FIFO ledger engine '
          'to allocate returned sarees against the oldest pending challans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final repo = ref.read(depositRequestRepositoryProvider);
    final result = await repo.approveDepositRequest(request.requestId);

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deposit request approved and challans updated.'),
          ),
        );
        onApproved();
      },
      failure: (err) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red),
                SizedBox(width: 8),
                Text('Approval Failed'),
              ],
            ),
            content: Text(err.message),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final reasonCtrl = TextEditingController();
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reject Deposit Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter reason for rejecting this deposit request:'),
            const SizedBox(height: 8),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason *',
                hintText: 'e.g. Physical count mismatch, defective sarees',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final reason = reasonCtrl.text.trim();
    if (reason.isEmpty) return;

    final repo = ref.read(depositRequestRepositoryProvider);
    final result = await repo.rejectDepositRequest(
      requestId: request.requestId,
      reason: reason,
    );

    result.when(
      success: (_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Deposit request rejected.')),
        );
        onRejected();
      },
      failure: (err) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${err.message}')),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dateStr =
        DateFormat('dd MMM yyyy, hh:mm a').format(request.submittedAt);
    final isPending = request.status == DepositRequestStatus.pending;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    const Icon(Icons.person, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Chip(
                  label: Text(
                    request.status.displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Submitted: $dateStr',
              style: TextStyle(color: theme.colorScheme.outline, fontSize: 12),
            ),
            if (request.notes != null && request.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text('Notes: ${request.notes!}'),
            ],
            if (request.rejectionReason != null) ...[
              const SizedBox(height: 4),
              Text(
                'Rejection Reason: ${request.rejectionReason!}',
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const Divider(height: 16),
            const Text(
              'Requested Return Quantities:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 6),
            ...request.items.map((item) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('SKU: ${item.sku}'),
                    Text(
                      '${item.requestedQuantity.toInt()} sarees',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              );
            }),
            if (isPending) ...[
              const Divider(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => _reject(context, ref),
                    style:
                        OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Reject'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: () => _approve(context, ref),
                    child: const Text('Approve & Allocate FIFO'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class ManualReturnDialog extends ConsumerStatefulWidget {
  const ManualReturnDialog({super.key});

  @override
  ConsumerState<ManualReturnDialog> createState() => _ManualReturnDialogState();
}

class _ManualReturnDialogState extends ConsumerState<ManualReturnDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  StitchingUserProfile? _selectedUser;
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
    if (_selectedUser == null ||
        _selectedProduct == null ||
        _selectedSku == null) {
      setState(() => _error = 'All fields are required.');
      return;
    }

    final qty = double.tryParse(_qtyCtrl.text.trim()) ?? 0;
    if (qty <= 0) {
      setState(() => _error = 'Positive return quantity required.');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(depositRequestRepositoryProvider);

    // SPEC §18 / §52: Check for same-day pending request
    final dupCheck = await repo.hasSameDayPendingDepositRequest(
      stitchingUserId: _selectedUser!.stitchingUserId,
      productId: _selectedProduct!.productId,
      sku: _selectedSku!.sku,
    );

    final hasDup = dupCheck.when(success: (v) => v, failure: (_) => false);
    if (hasDup) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Expanded(child: Text('Duplicate Request Warning')),
            ],
          ),
          content: Text(
            'An unverified deposit request already exists for ${_selectedUser!.name} '
            'for ${_selectedProduct!.name} / ${_selectedSku!.sku} submitted today.\n\n'
            'Please review and verify the user\'s pending deposit request before recording a manual return to prevent double-counting.',
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Go to Pending Requests'),
            ),
          ],
        ),
      );
      return;
    }

    // No duplicate found: Proceed with manual return
    final result = await repo.recordManualAdminReturn(
      stitchingUserId: _selectedUser!.stitchingUserId,
      productId: _selectedProduct!.productId,
      sku: _selectedSku!.sku,
      returnQuantity: qty,
      notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Manual production return recorded successfully.'),
          ),
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
    final usersAsync = ref.watch(stitchingUsersListProvider);
    final productsAsync = ref.watch(productsStreamProvider);

    return AlertDialog(
      title: const Text('Record Direct Manual Return'),
      content: SizedBox(
        width: 480,
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
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                usersAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (users) {
                    final activeUsers = users.where((u) => u.isActive).toList();
                    return DropdownButtonFormField<StitchingUserProfile>(
                      initialValue: _selectedUser,
                      decoration:
                          const InputDecoration(labelText: 'Stitching User *'),
                      items: activeUsers.map((u) {
                        return DropdownMenuItem(value: u, child: Text(u.name));
                      }).toList(),
                      onChanged: (u) => setState(() => _selectedUser = u),
                      validator: (v) => v == null ? 'User is required' : null,
                    );
                  },
                ),
                const SizedBox(height: 12),
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                  data: (products) {
                    final activeProducts =
                        products.where((p) => p.isActive).toList();
                    return DropdownButtonFormField<Product>(
                      initialValue: _selectedProduct,
                      decoration: const InputDecoration(labelText: 'Product *'),
                      items: activeProducts.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} (${p.productCode})'),
                        );
                      }).toList(),
                      onChanged: (p) => setState(() {
                        _selectedProduct = p;
                        _selectedSku = null;
                      }),
                      validator: (v) =>
                          v == null ? 'Product is required' : null,
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
                          final activeSkus =
                              skus.where((s) => s.isActive).toList();
                          return DropdownButtonFormField<ProductSku>(
                            initialValue: _selectedSku,
                            decoration:
                                const InputDecoration(labelText: 'Color SKU *'),
                            items: activeSkus.map((sku) {
                              return DropdownMenuItem(
                                value: sku,
                                child: Text('${sku.colorName} (${sku.sku})'),
                              );
                            }).toList(),
                            onChanged: (sku) =>
                                setState(() => _selectedSku = sku),
                            validator: (v) =>
                                v == null ? 'SKU is required' : null,
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
                    hintText: 'e.g. 50',
                  ),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                      ? 'Valid positive quantity required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration:
                      const InputDecoration(labelText: 'Notes (Optional)'),
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
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Record Return'),
        ),
      ],
    );
  }
}

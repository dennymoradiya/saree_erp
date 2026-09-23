import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/utils/whatsapp_share_helper.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/domain/create_challan_input.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/suppliers/domain/supplier.dart';
import 'package:saree_sutra/features/suppliers/presentation/controllers/suppliers_providers.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class CreateChallanScreen extends ConsumerStatefulWidget {
  const CreateChallanScreen({super.key});

  @override
  ConsumerState<CreateChallanScreen> createState() =>
      _CreateChallanScreenState();
}

class _CreateChallanScreenState extends ConsumerState<CreateChallanScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();

  String? _selectedSupplierId;
  String? _selectedStitchingUserId;

  final List<_ChallanItemDraft> _items = [_ChallanItemDraft()];
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add(_ChallanItemDraft());
    });
  }

  void _removeItem(int index) {
    if (_items.length <= 1) return;
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  Future<void> _submitChallan() async {
    if (!_formKey.currentState!.validate()) return;

    final authUser = ref.read(authStateChangesProvider).value;
    final isSupplier = authUser?.role == UserRole.supplier;
    final supplierId = isSupplier ? authUser?.supplierId : _selectedSupplierId;

    if (supplierId == null) {
      setState(() => _error = 'Please select a supplier.');
      return;
    }
    if (_selectedStitchingUserId == null) {
      setState(() => _error = 'Please select a stitching user.');
      return;
    }

    final itemInputs = <CreateChallanItemInput>[];
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.selectedProduct == null || item.selectedSku == null) {
        setState(
          () => _error = 'Please select a product and SKU for item #${i + 1}.',
        );
        return;
      }
      final sareeQty = double.tryParse(item.sareeQtyCtrl.text.trim()) ?? 0;
      if (sareeQty <= 0) {
        setState(
          () => _error =
              'Saree target quantity must be greater than 0 for item #${i + 1}.',
        );
        return;
      }

      final sareeText = item.sareeSuppliedCtrl.text.trim();
      final laceText = item.laceSuppliedCtrl.text.trim();
      final blouseText = item.blouseSuppliedCtrl.text.trim();

      final sareeSupplied =
          double.tryParse(sareeText) ?? (sareeText.isEmpty ? sareeQty : 0.0);
      final laceSupplied = item.selectedProduct!.requiresLace
          ? (double.tryParse(laceText) ?? (laceText.isEmpty ? sareeQty : 0.0))
          : 0.0;
      final blouseSupplied = item.selectedProduct!.requiresBlouse
          ? (double.tryParse(blouseText) ??
              (blouseText.isEmpty ? sareeQty : 0.0))
          : 0.0;

      if (sareeSupplied <= 0 && laceSupplied <= 0 && blouseSupplied <= 0) {
        setState(
          () => _error =
              'At least one material component must have a supplied quantity (> 0) for item #${i + 1}.',
        );
        return;
      }

      itemInputs.add(
        CreateChallanItemInput(
          productId: item.selectedProduct!.productId,
          sku: item.selectedSku!.sku,
          productNameSnapshot: item.selectedProduct!.name,
          skuSnapshot: item.selectedSku!.sku,
          colorNameSnapshot: item.selectedSku!.colorName,
          requiresSaree: item.selectedProduct!.requiresSaree,
          requiresLace: item.selectedProduct!.requiresLace,
          requiresBlouse: item.selectedProduct!.requiresBlouse,
          sareeIssuedQuantity: sareeQty,
          sareeSuppliedQuantity: sareeSupplied,
          laceSuppliedQuantity: laceSupplied,
          blouseSuppliedQuantity: blouseSupplied,
        ),
      );
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final repo = ref.read(challanRepositoryProvider);
    final result = await repo.createChallan(
      CreateChallanInput(
        supplierId: supplierId,
        stitchingUserId: _selectedStitchingUserId!,
        items: itemInputs,
        notes:
            _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
        creatorRole: isSupplier ? 'supplier' : 'admin',
      ),
    );

    if (!mounted) return;

    result.when(
      success: (challan) {
        final suppliers = ref.read(suppliersListProvider).asData?.value ?? [];
        final stitchingUsers =
            ref.read(stitchingUsersListProvider).asData?.value ?? [];

        var supplierName = supplierId;
        for (final s in suppliers) {
          if (s.supplierId == supplierId) {
            supplierName = s.name;
            break;
          }
        }

        var stitchingUserName = _selectedStitchingUserId!;
        String? stitchingUserPhone;
        for (final u in stitchingUsers) {
          if (u.stitchingUserId == _selectedStitchingUserId) {
            stitchingUserName = u.name;
            stitchingUserPhone = u.phone;
            break;
          }
        }

        final shareItems = itemInputs.map((item) {
          return ChallanItemShareData(
            productName: item.productNameSnapshot,
            sku: item.skuSnapshot,
            colorName: item.colorNameSnapshot,
            targetQuantity: item.sareeIssuedQuantity,
            sareeSupplied: item.sareeSuppliedQuantity,
            laceSupplied: item.laceSuppliedQuantity,
            blouseSupplied: item.blouseSuppliedQuantity,
            sareePending: item.sareeShortage,
            lacePending: item.laceShortage,
            blousePending: item.blouseShortage,
            requiresLace: item.requiresLace,
            requiresBlouse: item.requiresBlouse,
          );
        }).toList();

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogCtx) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Challan Created'),
              ],
            ),
            content: Text(
              'Challan ${challan.challanNumber} has been successfully issued. '
              'Material allocations and FIFO settlements have been processed.',
            ),
            actions: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF25D366),
                  side: const BorderSide(color: Color(0xFF25D366)),
                ),
                onPressed: () {
                  final message = WhatsAppShareHelper.formatChallanMessage(
                    challanNumber: challan.challanNumber,
                    createdAt: DateTime.now(),
                    supplierName: supplierName,
                    stitchingUserName: stitchingUserName,
                    notes: _notesCtrl.text.trim().isNotEmpty
                        ? _notesCtrl.text.trim()
                        : null,
                    items: shareItems,
                  );
                  WhatsAppShareHelper.shareToWhatsApp(
                    phoneNumber: stitchingUserPhone,
                    message: message,
                  );
                },
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Share on WhatsApp'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogCtx).pop();
                  context.pop();
                },
                child: const Text('Done'),
              ),
            ],
          ),
        );
      },
      failure: (err) {
        setState(() {
          _error = err.message;
          _isSubmitting = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateChangesProvider).value;
    final isSupplier = authUser?.role == UserRole.supplier;
    if (isSupplier &&
        _selectedSupplierId == null &&
        authUser?.supplierId != null) {
      _selectedSupplierId = authUser!.supplierId;
    }

    final suppliersAsync = ref.watch(suppliersListProvider);
    final stitchingUsersAsync = ref.watch(stitchingUsersListProvider);
    final productsAsync = ref.watch(productsStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isSupplier ? 'Create Delivery Challan' : 'Create Multi-Item Challan',
        ),
      ),
      body: suppliersAsync.when(
        loading: () => const LoadingView(message: 'Loading suppliers...'),
        error: (err, _) => ErrorView(message: 'Error loading suppliers: $err'),
        data: (suppliers) => stitchingUsersAsync.when(
          loading: () => const LoadingView(message: 'Loading manufacturers...'),
          error: (err, _) => ErrorView(message: 'Error loading users: $err'),
          data: (stitchingUsers) => productsAsync.when(
            loading: () => const LoadingView(message: 'Loading products...'),
            error: (err, _) =>
                ErrorView(message: 'Error loading products: $err'),
            data: (products) {
              final activeSuppliers =
                  suppliers.where((s) => s.isActive).toList();
              final activeUsers =
                  stitchingUsers.where((u) => u.isActive).toList();
              final activeProducts = products.where((p) => p.isActive).toList();

              Supplier? mySupplier;
              for (final s in suppliers) {
                if (s.supplierId == authUser?.supplierId) {
                  mySupplier = s;
                  break;
                }
              }
              final supplierDisplayName =
                  mySupplier?.name ?? authUser?.name ?? 'My Supply Business';

              return Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_error != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Text(
                            _error!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),

                      // Header Card: Supplier and Stitching User
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
                              Text(
                                'Challan Parties',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  if (isSupplier)
                                    Expanded(
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 12,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme.primaryContainer
                                              .withValues(alpha: 0.35),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          border: Border.all(
                                            color: theme.colorScheme.primary
                                                .withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 16,
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              child: const Icon(
                                                Icons.verified,
                                                size: 18,
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    'Supplier (Your Business)',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.grey,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    supplierDisplayName,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: 14,
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  else
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        initialValue: _selectedSupplierId,
                                        decoration: const InputDecoration(
                                          labelText: 'Supplier *',
                                          prefixIcon:
                                              Icon(Icons.business_outlined),
                                        ),
                                        items: activeSuppliers.map((s) {
                                          return DropdownMenuItem(
                                            value: s.supplierId,
                                            child: Text(s.name),
                                          );
                                        }).toList(),
                                        onChanged: (val) => setState(
                                          () => _selectedSupplierId = val,
                                        ),
                                        validator: (v) => v == null
                                            ? 'Supplier is required'
                                            : null,
                                      ),
                                    ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: DropdownButtonFormField<String>(
                                      initialValue: _selectedStitchingUserId,
                                      decoration: const InputDecoration(
                                        labelText:
                                            'Stitching User (Manufacturer) *',
                                        prefixIcon: Icon(Icons.person_outline),
                                      ),
                                      items: activeUsers.map((u) {
                                        return DropdownMenuItem(
                                          value: u.stitchingUserId,
                                          child: Text(u.name),
                                        );
                                      }).toList(),
                                      onChanged: (val) => setState(
                                        () => _selectedStitchingUserId = val,
                                      ),
                                      validator: (v) => v == null
                                          ? 'Stitching user is required'
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: _notesCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Notes (Optional)',
                                  prefixIcon: Icon(Icons.notes_outlined),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Items Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Challan Items (${_items.length})',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: _addItem,
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Item'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          return _ChallanItemCard(
                            key: ValueKey(_items[index]),
                            index: index,
                            draft: _items[index],
                            availableProducts: activeProducts,
                            canRemove: _items.length > 1,
                            onRemove: () => _removeItem(index),
                          );
                        },
                      ),
                      const SizedBox(height: 32),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _isSubmitting ? null : _submitChallan,
                          child: _isSubmitting
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Processing FIFO & Issuing Challan...',
                                    ),
                                  ],
                                )
                              : const Text(
                                  'Issue Challan',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ChallanItemDraft {
  Product? selectedProduct;
  ProductSku? selectedSku;

  final sareeQtyCtrl = TextEditingController();
  final sareeSuppliedCtrl = TextEditingController();
  final laceSuppliedCtrl = TextEditingController();
  final blouseSuppliedCtrl = TextEditingController();

  void dispose() {
    sareeQtyCtrl.dispose();
    sareeSuppliedCtrl.dispose();
    laceSuppliedCtrl.dispose();
    blouseSuppliedCtrl.dispose();
  }
}

class _ChallanItemCard extends ConsumerStatefulWidget {
  const _ChallanItemCard({
    super.key,
    required this.index,
    required this.draft,
    required this.availableProducts,
    required this.canRemove,
    required this.onRemove,
  });

  final int index;
  final _ChallanItemDraft draft;
  final List<Product> availableProducts;
  final bool canRemove;
  final VoidCallback onRemove;

  @override
  ConsumerState<_ChallanItemCard> createState() => _ChallanItemCardState();
}

class _ChallanItemCardState extends ConsumerState<_ChallanItemCard> {
  void _onSareeQuantityChanged(String value) {
    final qty = double.tryParse(value) ?? 0;
    if (qty > 0) {
      if (widget.draft.sareeSuppliedCtrl.text.isEmpty ||
          widget.draft.sareeSuppliedCtrl.text == '0') {
        widget.draft.sareeSuppliedCtrl.text = value;
      }
      if (widget.draft.selectedProduct?.requiresLace == true) {
        if (widget.draft.laceSuppliedCtrl.text.isEmpty ||
            widget.draft.laceSuppliedCtrl.text == '0') {
          widget.draft.laceSuppliedCtrl.text = value;
        }
      }
      if (widget.draft.selectedProduct?.requiresBlouse == true) {
        if (widget.draft.blouseSuppliedCtrl.text.isEmpty ||
            widget.draft.blouseSuppliedCtrl.text == '0') {
          widget.draft.blouseSuppliedCtrl.text = value;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final draft = widget.draft;
    final theme = Theme.of(context);
    final product = draft.selectedProduct;

    final targetQty = double.tryParse(draft.sareeQtyCtrl.text) ?? 0;
    final sareeText = draft.sareeSuppliedCtrl.text.trim();
    final laceText = draft.laceSuppliedCtrl.text.trim();
    final blouseText = draft.blouseSuppliedCtrl.text.trim();

    final sareeDelivered =
        double.tryParse(sareeText) ?? (sareeText.isEmpty ? targetQty : 0.0);
    final laceDelivered = product?.requiresLace == true
        ? (double.tryParse(laceText) ?? (laceText.isEmpty ? targetQty : 0.0))
        : 0.0;
    final blouseDelivered = product?.requiresBlouse == true
        ? (double.tryParse(blouseText) ??
            (blouseText.isEmpty ? targetQty : 0.0))
        : 0.0;

    final sareeShortage =
        product?.requiresSaree == true && targetQty > sareeDelivered
            ? (targetQty - sareeDelivered)
            : 0.0;
    final laceShortage =
        product?.requiresLace == true && targetQty > laceDelivered
            ? (targetQty - laceDelivered)
            : 0.0;
    final blouseShortage =
        product?.requiresBlouse == true && targetQty > blouseDelivered
            ? (targetQty - blouseDelivered)
            : 0.0;

    return Card(
      elevation: 2,
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
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Text(
                        '#${widget.index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Product Item',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (widget.canRemove)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: widget.onRemove,
                    tooltip: 'Remove Item',
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Product selection
            DropdownButtonFormField<Product>(
              initialValue: draft.selectedProduct,
              decoration: const InputDecoration(
                labelText: 'Select Product *',
                prefixIcon: Icon(Icons.checkroom_outlined),
              ),
              items: widget.availableProducts.map((p) {
                return DropdownMenuItem(
                  value: p,
                  child: Text('${p.name} (${p.productCode})'),
                );
              }).toList(),
              onChanged: (p) {
                setState(() {
                  draft.selectedProduct = p;
                  draft.selectedSku = null;
                  if (p?.requiresLace == false) {
                    draft.laceSuppliedCtrl.text = '0';
                  }
                  if (p?.requiresBlouse == false) {
                    draft.blouseSuppliedCtrl.text = '0';
                  }
                });
              },
              validator: (v) => v == null ? 'Product is required' : null,
            ),
            const SizedBox(height: 12),

            // SKU selection
            if (draft.selectedProduct != null) ...[
              Consumer(
                builder: (context, ref, child) {
                  final skusAsync = ref.watch(
                    productSkusStreamProvider(draft.selectedProduct!.productId),
                  );
                  return skusAsync.when(
                    loading: () => const LinearProgressIndicator(),
                    error: (e, _) => Text('Error loading SKUs: $e'),
                    data: (skus) {
                      final activeSkus = skus.where((s) => s.isActive).toList();
                      return DropdownButtonFormField<ProductSku>(
                        initialValue: draft.selectedSku,
                        decoration: const InputDecoration(
                          labelText: 'Color SKU (Variant) *',
                          prefixIcon: Icon(Icons.color_lens_outlined),
                        ),
                        items: activeSkus.map((sku) {
                          return DropdownMenuItem(
                            value: sku,
                            child: Text('${sku.colorName} (${sku.sku})'),
                          );
                        }).toList(),
                        onChanged: (sku) =>
                            setState(() => draft.selectedSku = sku),
                        validator: (v) => v == null ? 'SKU is required' : null,
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 12),

              // Target Saree Quantity (Spec §5: auto-fills Lace & Blouse)
              TextFormField(
                controller: draft.sareeQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saree Issue Target Quantity *',
                  hintText: 'e.g. 100',
                  prefixIcon: Icon(Icons.tag),
                ),
                // onChanged: _onSareeQuantityChanged,
                validator: (v) {
                  final n = double.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'Valid positive quantity required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Material Delivery Presets:',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Wrap(
                    spacing: 4,
                    children: [
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () {
                          final target = draft.sareeQtyCtrl.text.trim();
                          if (target.isEmpty) return;
                          setState(() {
                            draft.sareeSuppliedCtrl.text = target;
                            if (product?.requiresLace == true) {
                              draft.laceSuppliedCtrl.text = target;
                            }
                            if (product?.requiresBlouse == true) {
                              draft.blouseSuppliedCtrl.text = target;
                            }
                          });
                        },
                        child: const Text(
                          'Full Set',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () {
                          final target = draft.sareeQtyCtrl.text.trim();
                          if (target.isEmpty) return;
                          setState(() {
                            draft.sareeSuppliedCtrl.text = '0';
                            if (product?.requiresLace == true) {
                              draft.laceSuppliedCtrl.text = target;
                            }
                            if (product?.requiresBlouse == true) {
                              draft.blouseSuppliedCtrl.text = target;
                            }
                          });
                        },
                        child: const Text(
                          'Lace & Blouse First',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                        ),
                        onPressed: () {
                          final target = draft.sareeQtyCtrl.text.trim();
                          if (target.isEmpty) return;
                          setState(() {
                            draft.sareeSuppliedCtrl.text = target;
                            if (product?.requiresLace == true) {
                              draft.laceSuppliedCtrl.text = '0';
                            }
                            if (product?.requiresBlouse == true) {
                              draft.blouseSuppliedCtrl.text = '0';
                            }
                          });
                        },
                        child: const Text(
                          'Plain Saree First',
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Saree delivered
              TextFormField(
                controller: draft.sareeSuppliedCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Saree Fabric Supplied',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 8),

              // Lace delivered
              if (draft.selectedProduct?.requiresLace == true)
                TextFormField(
                  controller: draft.laceSuppliedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Lace Pieces Supplied',
                    prefixIcon: Icon(Icons.content_cut_outlined),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'Lace: Not required for this product',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),

              // Blouse delivered
              if (draft.selectedProduct?.requiresBlouse == true)
                TextFormField(
                  controller: draft.blouseSuppliedCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Blouse Pieces Supplied',
                    prefixIcon: Icon(Icons.checkroom),
                  ),
                  onChanged: (_) => setState(() {}),
                )
              else
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: Colors.grey),
                      SizedBox(width: 6),
                      Text(
                        'Blouse: Not required for this product',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

              // Shortage warning highlight
              if (sareeShortage > 0 ||
                  laceShortage > 0 ||
                  blouseShortage > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pending Materials To Complete Set:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            if (sareeShortage > 0)
                              Text(
                                '• Plain Saree Fabric Pending: ${sareeShortage.toInt()} pcs (Admin owes to manufacturer)',
                                style:
                                    const TextStyle(color: Colors.deepOrange),
                              ),
                            if (laceShortage > 0)
                              Text(
                                '• Lace Pending: ${laceShortage.toInt()} pcs (Supplier owes to manufacturer)',
                                style:
                                    const TextStyle(color: Colors.deepOrange),
                              ),
                            if (blouseShortage > 0)
                              Text(
                                '• Blouse Pending: ${blouseShortage.toInt()} pcs (Supplier owes to manufacturer)',
                                style:
                                    const TextStyle(color: Colors.deepOrange),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

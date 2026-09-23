import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/deposit_requests/domain/deposit_request.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/controllers/deposit_request_providers.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';

/// Dialog allowing a stitching unit to submit a deposit request for finished saree returns.
class CreateDepositRequestDialog extends ConsumerStatefulWidget {
  const CreateDepositRequestDialog({
    super.key,
    required this.stitchingUserId,
    this.initialProductId,
    this.initialSku,
  });

  final String stitchingUserId;
  final String? initialProductId;
  final String? initialSku;

  @override
  ConsumerState<CreateDepositRequestDialog> createState() =>
      _CreateDepositRequestDialogState();
}

class _CreateDepositRequestDialogState
    extends ConsumerState<CreateDepositRequestDialog> {
  final _formKey = GlobalKey<FormState>();
  final _qtyCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Product? _selectedProduct;
  ProductSku? _selectedSku;
  bool _isLoading = false;
  String? _error;
  bool _hasInitializedSelection = false;

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
          const SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Deposit request submitted! Awaiting admin verification.'),
              ],
            ),
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
    final productsAsync = ref.watch(productsStreamProvider);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Row(
        children: [
          Icon(Icons.assignment_return, color: Colors.teal),
          SizedBox(width: 8),
          Text('Submit Finished Return'),
        ],
      ),
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
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: Colors.red, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(_error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                productsAsync.when(
                  loading: () => const LinearProgressIndicator(),
                  error: (e, _) => Text('Error loading products: $e'),
                  data: (products) {
                    final activeProducts =
                        products.where((p) => p.isActive).toList();

                    // Pre-select if initialProductId passed
                    if (!_hasInitializedSelection &&
                        widget.initialProductId != null) {
                      for (final p in activeProducts) {
                        if (p.productId == widget.initialProductId) {
                          _selectedProduct = p;
                          break;
                        }
                      }
                      _hasInitializedSelection = true;
                    }

                    return DropdownButtonFormField<Product>(
                      value: _selectedProduct,
                      decoration: const InputDecoration(
                        labelText: 'Product *',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                      items: activeProducts.map((p) {
                        return DropdownMenuItem(
                          value: p,
                          child: Text('${p.name} (${p.productCode})',
                              overflow: TextOverflow.ellipsis),
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
                        error: (e, _) => Text('Error loading SKUs: $e'),
                        data: (skus) {
                          final activeSkus =
                              skus.where((s) => s.isActive).toList();

                          if (_selectedSku == null &&
                              widget.initialSku != null) {
                            for (final s in activeSkus) {
                              if (s.sku == widget.initialSku) {
                                _selectedSku = s;
                                break;
                              }
                            }
                          }

                          return DropdownButtonFormField<ProductSku>(
                            value: _selectedSku,
                            decoration: const InputDecoration(
                              labelText: 'Color SKU *',
                              border: OutlineInputBorder(),
                              isDense: true,
                            ),
                            items: activeSkus.map((sku) {
                              return DropdownMenuItem(
                                value: sku,
                                child: Text(
                                  '${sku.colorName} (${sku.sku})',
                                  overflow: TextOverflow.ellipsis,
                                ),
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
                    hintText: 'e.g. 80',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => (double.tryParse(v ?? '') ?? 0) <= 0
                      ? 'Positive quantity required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Remarks (Optional)',
                    hintText: 'e.g. Batch #1 completed',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
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
        FilledButton.icon(
          onPressed: _isLoading ? null : _submit,
          icon: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check, size: 18),
          label: Text(_isLoading ? 'Submitting...' : 'Submit Request'),
        ),
      ],
    );
  }
}

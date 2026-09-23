import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';

/// Dialog allowing suppliers or admins to complete/supply remaining materials for a challan item.
class FulfillSupplierMaterialDialog extends ConsumerStatefulWidget {
  const FulfillSupplierMaterialDialog({
    super.key,
    required this.challan,
    required this.item,
  });

  final Challan challan;
  final ChallanItem item;

  @override
  ConsumerState<FulfillSupplierMaterialDialog> createState() =>
      _FulfillSupplierMaterialDialogState();
}

class _FulfillSupplierMaterialDialogState
    extends ConsumerState<FulfillSupplierMaterialDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _sareeCtrl;
  late final TextEditingController _laceCtrl;
  late final TextEditingController _blouseCtrl;
  final _notesCtrl = TextEditingController();

  bool _isSubmitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sareeCtrl = TextEditingController(
      text: widget.item.sareePendingSupplierQuantity > 0
          ? widget.item.sareePendingSupplierQuantity.toInt().toString()
          : '0',
    );
    _laceCtrl = TextEditingController(
      text: widget.item.lacePendingSupplierQuantity > 0
          ? widget.item.lacePendingSupplierQuantity.toInt().toString()
          : '0',
    );
    _blouseCtrl = TextEditingController(
      text: widget.item.blousePendingSupplierQuantity > 0
          ? widget.item.blousePendingSupplierQuantity.toInt().toString()
          : '0',
    );
  }

  @override
  void dispose() {
    _sareeCtrl.dispose();
    _laceCtrl.dispose();
    _blouseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final sareeQty = double.tryParse(_sareeCtrl.text.trim()) ?? 0;
    final laceQty = double.tryParse(_laceCtrl.text.trim()) ?? 0;
    final blouseQty = double.tryParse(_blouseCtrl.text.trim()) ?? 0;

    if (sareeQty <= 0 && laceQty <= 0 && blouseQty <= 0) {
      setState(() {
        _error = 'Please enter at least one quantity to supply.';
      });
      return;
    }

    if (sareeQty > widget.item.sareePendingSupplierQuantity) {
      setState(() {
        _error =
            'Saree quantity cannot exceed pending balance of ${widget.item.sareePendingSupplierQuantity.toInt()}.';
      });
      return;
    }
    if (laceQty > widget.item.lacePendingSupplierQuantity) {
      setState(() {
        _error =
            'Lace quantity cannot exceed pending balance of ${widget.item.lacePendingSupplierQuantity.toInt()}.';
      });
      return;
    }
    if (blouseQty > widget.item.blousePendingSupplierQuantity) {
      setState(() {
        _error =
            'Blouse quantity cannot exceed pending balance of ${widget.item.blousePendingSupplierQuantity.toInt()}.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    final repo = ref.read(challanRepositoryProvider);
    final result = await repo.fulfillSupplierMaterial(
      challanId: widget.challan.challanId,
      challanItemId: widget.item.challanItemId,
      sareeQuantity: sareeQty,
      laceQuantity: laceQty,
      blouseQuantity: blouseQty,
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
                Text('Material delivery recorded with date and time!'),
              ],
            ),
          ),
        );
      },
      failure: (err) {
        setState(() {
          _isSubmitting = false;
          _error = err.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.add_shopping_cart, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          const Expanded(child: Text('Supply Remaining Material')),
        ],
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productNameSnapshot,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'SKU: ${item.skuSnapshot} ${item.colorNameSnapshot != null ? "(${item.colorNameSnapshot})" : ""}',
                      style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_error != null) ...[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Saree input (if pending)
              if (item.sareePendingSupplierQuantity > 0) ...[
                _buildQuantityField(
                  controller: _sareeCtrl,
                  label: 'Saree Pieces',
                  pending: item.sareePendingSupplierQuantity,
                  icon: Icons.checkroom,
                  color: Colors.blue,
                ),
                const SizedBox(height: 12),
              ],

              // Lace input (if pending)
              if (item.lacePendingSupplierQuantity > 0) ...[
                _buildQuantityField(
                  controller: _laceCtrl,
                  label: 'Lace Pieces',
                  pending: item.lacePendingSupplierQuantity,
                  icon: Icons.line_style,
                  color: Colors.amber.shade800,
                ),
                const SizedBox(height: 12),
              ],

              // Blouse input (if pending)
              if (item.blousePendingSupplierQuantity > 0) ...[
                _buildQuantityField(
                  controller: _blouseCtrl,
                  label: 'Blouse Pieces',
                  pending: item.blousePendingSupplierQuantity,
                  icon: Icons.dry_cleaning,
                  color: Colors.purple,
                ),
                const SizedBox(height: 12),
              ],

              TextField(
                controller: _notesCtrl,
                decoration: const InputDecoration(
                  labelText: 'Delivery Notes (Optional)',
                  hintText: 'e.g. Delivered remaining pieces',
                  prefixIcon: Icon(Icons.notes),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Confirm Delivery'),
        ),
      ],
    );
  }

  Widget _buildQuantityField({
    required TextEditingController controller,
    required String label,
    required double pending,
    required IconData icon,
    required Color color,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: '$label (Pending: ${pending.toInt()})',
        prefixIcon: Icon(icon, color: color),
        suffixIcon: TextButton(
          onPressed: () {
            controller.text = pending.toInt().toString();
          },
          child: const Text('MAX', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      ),
      validator: (v) {
        final val = double.tryParse(v ?? '');
        if (val == null || val < 0) {
          return 'Enter 0 or positive number';
        }
        if (val > pending) {
          return 'Max allowed is ${pending.toInt()}';
        }
        return null;
      },
    );
  }
}

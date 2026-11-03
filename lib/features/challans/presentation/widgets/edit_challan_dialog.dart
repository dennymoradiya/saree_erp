import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/challans/domain/challan.dart';
import 'package:saree_sutra/features/challans/domain/challan_item.dart';
import 'package:saree_sutra/features/challans/domain/edit_challan_input.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';

Future<void> showEditChallanDialog(BuildContext context, Challan challan) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => EditChallanDialog(challan: challan),
  );
}

class EditChallanDialog extends ConsumerStatefulWidget {
  const EditChallanDialog({super.key, required this.challan});

  final Challan challan;

  @override
  ConsumerState<EditChallanDialog> createState() => _EditChallanDialogState();
}

class _EditChallanDialogState extends ConsumerState<EditChallanDialog> {
  final _formKey = GlobalKey<FormState>();
  final _notesCtrl = TextEditingController();
  final _issuedCtrls = <String, TextEditingController>{};
  final _returnedCtrls = <String, TextEditingController>{};

  bool _initialized = false;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _notesCtrl.text = widget.challan.notes ?? '';
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    for (final c in _issuedCtrls.values) {
      c.dispose();
    }
    for (final c in _returnedCtrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _ensureControllers(List<ChallanItem> items) {
    if (_initialized) return;
    _initialized = true;
    for (final item in items) {
      _issuedCtrls[item.challanItemId] = TextEditingController(
        text: _formatQty(item.sareeIssuedQuantity),
      );
      _returnedCtrls[item.challanItemId] = TextEditingController(
        text: _formatQty(item.sareeReturnedQuantity),
      );
    }
  }

  String _formatQty(double qty) {
    if (qty == qty.roundToDouble()) return qty.toInt().toString();
    return qty.toString();
  }

  Future<void> _submit(List<ChallanItem> items) async {
    if (!_formKey.currentState!.validate()) return;

    final edits = <ChallanItemEdit>[];
    for (final item in items) {
      final issued =
          double.tryParse(_issuedCtrls[item.challanItemId]?.text.trim() ?? '') ??
              -1;
      final returned = double.tryParse(
            _returnedCtrls[item.challanItemId]?.text.trim() ?? '',
          ) ??
          -1;
      if (issued < 0 || returned < 0) {
        setState(() => _error = 'Enter valid non-negative quantities.');
        return;
      }
      if (returned > issued) {
        setState(
          () => _error =
              'Deposit quantity cannot exceed issued quantity for ${item.productNameSnapshot}.',
        );
        return;
      }
      edits.add(
        ChallanItemEdit(
          challanItemId: item.challanItemId,
          sareeIssuedQuantity: issued,
          sareeReturnedQuantity: returned,
        ),
      );
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final result = await ref.read(challanRepositoryProvider).updateChallan(
          challanId: widget.challan.challanId,
          notes: _notesCtrl.text.trim().isNotEmpty ? _notesCtrl.text.trim() : null,
          itemEdits: edits,
        );

    if (!mounted) return;
    result.when(
      success: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Challan updated successfully.')),
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
    final itemsAsync =
        ref.watch(challanItemsStreamProvider(widget.challan.challanId));

    return AlertDialog(
      title: Text('Edit ${widget.challan.challanNumber}'),
      content: SizedBox(
        width: 560,
        child: itemsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.all(24),
            child: LoadingView(message: 'Loading items...'),
          ),
          error: (err, _) => ErrorView(message: err.toString()),
          data: (items) {
            if (items.isEmpty) {
              return const Text('No items recorded for this challan.');
            }
            _ensureControllers(items);
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_error != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        margin: const EdgeInsets.only(bottom: 12),
                        color: Colors.red.shade50,
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    TextFormField(
                      controller: _notesCtrl,
                      enabled: !_isLoading,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Notes',
                        hintText: 'Optional challan notes',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Line items — Issued qty and Deposit (returned) qty',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${item.productNameSnapshot} — ${item.colorNameSnapshot ?? item.skuSnapshot}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _issuedCtrls[item.challanItemId],
                                        enabled: !_isLoading,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Issued Qty *',
                                          isDense: true,
                                        ),
                                        validator: (v) =>
                                            (double.tryParse(v ?? '') ?? -1) < 0
                                                ? 'Required'
                                                : null,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: TextFormField(
                                        controller:
                                            _returnedCtrls[item.challanItemId],
                                        enabled: !_isLoading,
                                        keyboardType: TextInputType.number,
                                        decoration: const InputDecoration(
                                          labelText: 'Deposit Qty *',
                                          isDense: true,
                                        ),
                                        validator: (v) =>
                                            (double.tryParse(v ?? '') ?? -1) < 0
                                                ? 'Required'
                                                : null,
                                        onChanged: (_) => setState(() {}),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Pending: ${_pendingFor(item)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading
              ? null
              : () {
                  final items = itemsAsync.asData?.value;
                  if (items == null || items.isEmpty) return;
                  _submit(items);
                },
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  String _pendingFor(ChallanItem item) {
    final issued =
        double.tryParse(_issuedCtrls[item.challanItemId]?.text.trim() ?? '');
    final returned =
        double.tryParse(_returnedCtrls[item.challanItemId]?.text.trim() ?? '');
    if (issued == null || returned == null) return '—';
    final pending = issued - returned;
    if (pending < 0) return 'invalid';
    return _formatQty(pending);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/products/domain/product.dart';
import 'package:saree_sutra/features/products/domain/product_sku.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Products & Colors (SKUs)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Product',
            onPressed: () => _showAddProductDialog(context),
          ),
        ],
      ),
      body: productsAsync.when(
        loading: () => const LoadingView(message: 'Loading products...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(productsStreamProvider),
        ),
        data: (products) {
          final filtered = products.where((p) {
            final q = _searchQuery.toLowerCase();
            return p.name.toLowerCase().contains(q) ||
                p.productCode.toLowerCase().contains(q);
          }).toList();

          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inventory_2_outlined,
                      size: 48, color: Colors.grey,),
                  const SizedBox(height: 12),
                  const Text('No Products Created',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 4),
                  const Text(
                      'Create products and color SKUs to start generating challans.',),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _showAddProductDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add First Product'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search products by name or code...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) => setState(() => _searchQuery = val),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final product = filtered[index];
                    return _ProductExpansionCard(product: product);
                  },
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddProductDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('New Product'),
      ),
    );
  }

  void _showAddProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _AddProductDialog(),
    );
  }
}

class _ProductExpansionCard extends ConsumerWidget {
  const _ProductExpansionCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skusAsync = ref.watch(productSkusStreamProvider(product.productId));
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                product.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                product.productCode,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              _MaterialBadge(
                label: 'Saree',
                enabled: product.requiresSaree,
              ),
              _MaterialBadge(
                label: 'Lace',
                enabled: product.requiresLace,
              ),
              _MaterialBadge(
                label: 'Blouse',
                enabled: product.requiresBlouse,
              ),
            ],
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit_outlined, size: 20),
          tooltip: 'Edit Product & Materials',
          onPressed: () => _showEditProductDialog(context),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Color SKUs (Variants)',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddSkuDialog(context, ref),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add Color SKU'),
                ),
              ],
            ),
          ),
          skusAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Error loading SKUs: $err'),
            ),
            data: (skus) {
              if (skus.isEmpty) {
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'No color SKUs added yet. Click "Add Color SKU" to add variants.',
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                  ),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: skus.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, idx) {
                  final sku = skus[idx];
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      radius: 12,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      child: Text(
                        sku.colorName.isNotEmpty
                            ? sku.colorName[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text('${sku.colorName} (${sku.sku})'),
                    subtitle: Text('Variant key: ${sku.variantKey}'),
                    trailing: Switch.adaptive(
                      value: sku.isActive,
                      onChanged: (active) {
                        ref.read(productRepositoryProvider).toggleSkuStatus(
                              productId: product.productId,
                              sku: sku.sku,
                              isActive: active,
                            );
                      },
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showAddSkuDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _AddSkuDialog(productId: product.productId),
    );
  }

  void _showEditProductDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _EditProductDialog(product: product),
    );
  }
}

class _MaterialBadge extends StatelessWidget {
  const _MaterialBadge({required this.label, required this.enabled});

  final String label;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: enabled
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        enabled ? '✓ $label' : '✕ No $label',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: enabled
              ? theme.colorScheme.onSurfaceVariant
              : theme.colorScheme.outline,
        ),
      ),
    );
  }
}

class _AddProductDialog extends ConsumerStatefulWidget {
  const _AddProductDialog();

  @override
  ConsumerState<_AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends ConsumerState<_AddProductDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  bool _requiresSaree = true;
  bool _requiresLace = true;
  bool _requiresBlouse = true;

  final List<Map<String, String>> _initialSkus = [];
  final _skuCodeCtrl = TextEditingController();
  final _skuColorCtrl = TextEditingController();

  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _skuCodeCtrl.dispose();
    _skuColorCtrl.dispose();
    super.dispose();
  }

  void _addSkuToDraft() {
    final code = _skuCodeCtrl.text.trim().toUpperCase();
    final color = _skuColorCtrl.text.trim();
    if (code.isEmpty || color.isEmpty) return;
    setState(() {
      _initialSkus.add({'sku': code, 'colorName': color});
      _skuCodeCtrl.clear();
      _skuColorCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(productRepositoryProvider);
    final skus = _initialSkus.map((e) {
      return ProductSku(
        productId: '',
        sku: e['sku']!,
        colorName: e['colorName']!,
        isActive: true,
      );
    }).toList();

    final result = await repo.createProduct(
      name: _nameCtrl.text.trim(),
      productCode: _codeCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      requiresSaree: _requiresSaree,
      requiresLace: _requiresLace,
      requiresBlouse: _requiresBlouse,
      initialSkus: skus,
    );

    if (!mounted) return;
    result.when(
      success: (product) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Product "${product.name}" created successfully'),),
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
    return AlertDialog(
      title: const Text('Add New Product'),
      content: SizedBox(
        width: 500,
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
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red),),
                  ),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                    hintText: 'e.g. Banarasi Saree, Georgette Saree',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Code *',
                    hintText: 'e.g. PROD001, BAN001',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Code is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Material Components Required:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4,),
                          ),
                          onPressed: () {
                            setState(() {
                              _requiresSaree = true;
                              _requiresLace = false;
                              _requiresBlouse = false;
                            });
                          },
                          child: const Text('Only Raw Saree',
                              style: TextStyle(fontSize: 11),),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4,),
                          ),
                          onPressed: () {
                            setState(() {
                              _requiresSaree = true;
                              _requiresLace = true;
                              _requiresBlouse = true;
                            });
                          },
                          child: const Text('All Materials',
                              style: TextStyle(fontSize: 11),),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Saree Material'),
                  value: _requiresSaree,
                  onChanged: (v) => setState(() => _requiresSaree = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Lace Material'),
                  subtitle: const Text(
                      'Uncheck if this saree type does not use lace',),
                  value: _requiresLace,
                  onChanged: (v) => setState(() => _requiresLace = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Blouse Material'),
                  subtitle: const Text(
                      'Uncheck if this saree type does not use blouse piece',),
                  value: _requiresBlouse,
                  onChanged: (v) => setState(() => _requiresBlouse = v ?? true),
                ),
                const Divider(height: 24),
                const Text(
                  'Initial Color SKUs (Optional):',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: _skuCodeCtrl,
                        decoration: const InputDecoration(
                          hintText: 'SKU (e.g. RED001)',
                          isDense: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: _skuColorCtrl,
                        decoration: const InputDecoration(
                          hintText: 'Color (e.g. Crimson Red)',
                          isDense: true,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle, color: Colors.blue),
                      onPressed: _addSkuToDraft,
                    ),
                  ],
                ),
                if (_initialSkus.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Wrap(
                      spacing: 6,
                      children: _initialSkus.map((sku) {
                        return Chip(
                          label: Text('${sku['colorName']} (${sku['sku']})'),
                          onDeleted: () =>
                              setState(() => _initialSkus.remove(sku)),
                        );
                      }).toList(),
                    ),
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
              : const Text('Create Product'),
        ),
      ],
    );
  }
}

class _AddSkuDialog extends ConsumerStatefulWidget {
  const _AddSkuDialog({required this.productId});

  final String productId;

  @override
  ConsumerState<_AddSkuDialog> createState() => _AddSkuDialogState();
}

class _AddSkuDialogState extends ConsumerState<_AddSkuDialog> {
  final _skuCtrl = TextEditingController();
  final _colorCtrl = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _skuCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final sku = _skuCtrl.text.trim().toUpperCase();
    final color = _colorCtrl.text.trim();
    if (sku.isEmpty || color.isEmpty) {
      setState(() => _error = 'SKU and Color Name are required');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(productRepositoryProvider);
    final result = await repo.addProductSku(
      productId: widget.productId,
      sku: sku,
      colorName: color,
    );

    if (!mounted) return;
    result.when(
      success: (_) => Navigator.of(context).pop(),
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
    return AlertDialog(
      title: const Text('Add Color SKU'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          TextField(
            controller: _skuCtrl,
            decoration: const InputDecoration(
              labelText: 'SKU Code *',
              hintText: 'e.g. RED001, BLU002',
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _colorCtrl,
            decoration: const InputDecoration(
              labelText: 'Color Name *',
              hintText: 'e.g. Ruby Red, Sky Blue',
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
              : const Text('Add SKU'),
        ),
      ],
    );
  }
}

class _EditProductDialog extends ConsumerStatefulWidget {
  const _EditProductDialog({required this.product});

  final Product product;

  @override
  ConsumerState<_EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends ConsumerState<_EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;

  late bool _requiresSaree;
  late bool _requiresLace;
  late bool _requiresBlouse;

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.product.name);
    _codeCtrl = TextEditingController(text: widget.product.productCode);
    _descCtrl = TextEditingController(text: widget.product.description ?? '');
    _requiresSaree = widget.product.requiresSaree;
    _requiresLace = widget.product.requiresLace;
    _requiresBlouse = widget.product.requiresBlouse;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _codeCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final repo = ref.read(productRepositoryProvider);
    final result = await repo.updateProduct(
      productId: widget.product.productId,
      name: _nameCtrl.text.trim(),
      productCode: _codeCtrl.text.trim(),
      description:
          _descCtrl.text.trim().isNotEmpty ? _descCtrl.text.trim() : null,
      requiresSaree: _requiresSaree,
      requiresLace: _requiresLace,
      requiresBlouse: _requiresBlouse,
    );

    if (!mounted) return;
    result.when(
      success: (_) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully')),
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
    return AlertDialog(
      title: const Text('Edit Product & Materials'),
      content: SizedBox(
        width: 500,
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
                    child: Text(_error!,
                        style: const TextStyle(color: Colors.red),),
                  ),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Name *',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Name is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Product Code *',
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Code is required'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Material Components Required:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4,),
                          ),
                          onPressed: () {
                            setState(() {
                              _requiresSaree = true;
                              _requiresLace = false;
                              _requiresBlouse = false;
                            });
                          },
                          child: const Text('Only Raw Saree',
                              style: TextStyle(fontSize: 11),),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4,),
                          ),
                          onPressed: () {
                            setState(() {
                              _requiresSaree = true;
                              _requiresLace = true;
                              _requiresBlouse = true;
                            });
                          },
                          child: const Text('All Materials',
                              style: TextStyle(fontSize: 11),),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Saree Material'),
                  value: _requiresSaree,
                  onChanged: (v) => setState(() => _requiresSaree = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Lace Material'),
                  subtitle: const Text(
                      'Uncheck if this saree type does not use lace',),
                  value: _requiresLace,
                  onChanged: (v) => setState(() => _requiresLace = v ?? true),
                ),
                CheckboxListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Requires Blouse Material'),
                  subtitle: const Text(
                      'Uncheck if this saree type does not use blouse piece',),
                  value: _requiresBlouse,
                  onChanged: (v) => setState(() => _requiresBlouse = v ?? true),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
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
              : const Text('Save Changes'),
        ),
      ],
    );
  }
}

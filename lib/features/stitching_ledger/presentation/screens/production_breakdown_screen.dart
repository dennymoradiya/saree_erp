import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/features/products/presentation/controllers/product_providers.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_models.dart';

class ProductionBreakdownScreen extends StatelessWidget {
  const ProductionBreakdownScreen({
    super.key,
    required this.stitchingUnit,
    required this.period,
    required this.totals,
  });

  final String stitchingUnit;
  final String period;
  final List<ProductionReturnTotal> totals;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quantityFormat = NumberFormat.decimalPattern()
      ..maximumFractionDigits = 8;
    final totalUnits = totals.fold(0.0, (sum, row) => sum + row.quantity);

    return Scaffold(
      appBar: AppBar(title: const Text('Production Breakdown')),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: totals.length + 1,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stitchingUnit, style: theme.textTheme.titleLarge),
                    Text(period),
                    const SizedBox(height: 12),
                    Text(
                      '${quantityFormat.format(totalUnits)} finished sarees returned',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              );
            }

            final row = totals[index - 1];
            return Consumer(
              builder: (context, ref, _) {
                final skus = ref
                    .watch(productSkusStreamProvider(row.productId))
                    .asData
                    ?.value;
                final colorName = skus
                    ?.where((sku) => sku.sku == row.sku)
                    .firstOrNull
                    ?.colorName
                    .trim();
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(row.productName),
                  subtitle: Text(
                    colorName == null || colorName.isEmpty
                        ? 'SKU ${row.sku}'
                        : '$colorName · SKU ${row.sku}',
                  ),
                  trailing: Text(
                    quantityFormat.format(row.quantity),
                    style: theme.textTheme.titleMedium,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

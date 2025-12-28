import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// AppColors removed - using theme
import '../../core/services/comparison_service.dart';
import '../../data/models/component.dart';

class ComparisonTable extends ConsumerWidget {
  final List<Component> components;
  final bool showUSD;

  const ComparisonTable({
    super.key,
    required this.components,
    this.showUSD = false,
  });

  static const double usdToBdtRate = 120.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (components.isEmpty) {
      return const SizedBox.shrink();
    }

    final service = ref.watch(comparisonServiceProvider);
    final specKeys = service.getOrderedSpecKeys(components);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Specifications Comparison',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Table
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: DataTable(
                columnSpacing: 20,
                horizontalMargin: 0,
                headingRowHeight: 60,
                dataRowMinHeight: 48,
                dataRowMaxHeight: 72,
                border: TableBorder.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                  width: 1,
                ),
                columns: [
                  DataColumn(
                    label: Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(
                        'Specification',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                      ),
                    ),
                  ),
                  ...components.map((component) {
                    return DataColumn(
                      label: Container(
                        constraints: const BoxConstraints(
                          minWidth: 120,
                          maxWidth: 200,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              component.brand,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w500,
                                  ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              component.name.length > 25
                                  ? '${component.name.substring(0, 25)}...'
                                  : component.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
                rows: [
                  // Brand row
                  _buildDataRow(
                    context,
                    service,
                    'Brand',
                    components.map((c) => c.brand).toList(),
                    components,
                    isHeader: true,
                  ),

                  // Price rows
                  _buildDataRow(
                    context,
                    service,
                    showUSD ? 'Price (USD)' : 'Price (BDT)',
                    components.map((c) {
                      if (c.priceBdt == null) return '-';
                      return showUSD
                          ? '\$${(c.priceBdt! / usdToBdtRate).toStringAsFixed(2)}'
                          : '৳${c.priceBdt!.toStringAsFixed(0)}';
                    }).toList(),
                    components,
                    isPrice: true,
                  ),

                  // Specification rows
                  ...specKeys.map((specKey) {
                    final values = components.map((c) {
                      final value = c.specs?[specKey];
                      return service.getSpecDisplayValue(value);
                    }).toList();

                    return _buildDataRow(
                      context,
                      service,
                      service.formatSpecKey(specKey),
                      values,
                      components,
                      specKey: specKey,
                    );
                  }),
                ],
              ),
            ),
          ),

          // Footer note
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    showUSD
                        ? 'Prices shown in USD (1 USD ≈ ৳$usdToBdtRate)'
                        : 'Prices shown in BDT (৳$usdToBdtRate ≈ 1 USD)',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  DataRow _buildDataRow(
    BuildContext context,
    ComparisonService service,
    String label,
    List<String> values,
    List<Component> components, {
    String? specKey,
    bool isHeader = false,
    bool isPrice = false,
  }) {
    // Check if values differ
    final hasDifferences = values.toSet().length > 1;
    final shouldHighlight =
        specKey != null && service.specValuesAreDifferent(components, specKey);

    return DataRow(
      color: WidgetStateProperty.resolveWith<Color?>(
        (Set<WidgetState> states) {
          if (isHeader) {
            return Theme.of(context).colorScheme.primary.withOpacity(0.05);
          }
          if (shouldHighlight) {
            return Colors.orange.withOpacity(0.05);
          }
          return null;
        },
      ),
      cells: [
        DataCell(
          Container(
            constraints: const BoxConstraints(minWidth: 150),
            child: Row(
              children: [
                if (shouldHighlight)
                  Container(
                    width: 4,
                    height: 20,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                Expanded(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isHeader ? FontWeight.bold : FontWeight.w600,
                          color: isHeader
                              ? Theme.of(context).colorScheme.primary
                              : shouldHighlight
                                  ? Theme.of(context).colorScheme.onSurface
                                  : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        ...values.map((value) {
          return DataCell(
            Container(
              constraints: const BoxConstraints(
                minWidth: 120,
                maxWidth: 200,
              ),
              child: Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: isPrice ? FontWeight.bold : FontWeight.normal,
                      color: isPrice
                          ? Theme.of(context).colorScheme.primary
                          : shouldHighlight
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        }),
      ],
    );
  }
}

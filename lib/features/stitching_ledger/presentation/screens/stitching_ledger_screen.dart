import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_by_id_screen.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/stitching_ledger_models.dart';
import 'package:saree_sutra/features/stitching_ledger/presentation/controllers/stitching_ledger_providers.dart';
import 'package:saree_sutra/features/supplier_ledger/presentation/controllers/supplier_ledger_providers.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

class StitchingLedgerScreen extends ConsumerStatefulWidget {
  const StitchingLedgerScreen({super.key, this.initialStitchingUserId});

  final String? initialStitchingUserId;

  @override
  ConsumerState<StitchingLedgerScreen> createState() =>
      _StitchingLedgerScreenState();
}

class _StitchingLedgerScreenState extends ConsumerState<StitchingLedgerScreen> {
  late final String? _effectiveStitchingUserId;

  @override
  void initState() {
    super.initState();
    final authUser = ref.read(authStateChangesProvider).value;
    final isAdmin = authUser?.role == UserRole.admin;
    if (authUser?.role == UserRole.stitchingUser) {
      _effectiveStitchingUserId = authUser?.stitchingUserId;
    } else {
      _effectiveStitchingUserId = widget.initialStitchingUserId;
    }

    if (!isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final currentFilter = ref
            .read(stitchingLedgerFilterProvider(_effectiveStitchingUserId))
            .dateFilter;
        if (currentFilter == LedgerDateFilter.allTime) {
          ref
              .read(stitchingLedgerFilterProvider(_effectiveStitchingUserId).notifier)
              .setDateFilter(LedgerDateFilter.thisMonth);
        }
      });
    }
  }

  Future<void> _selectCustomDateRange(BuildContext context) async {
    final filterState =
        ref.read(stitchingLedgerFilterProvider(_effectiveStitchingUserId));
    final initialRange = DateTimeRange(
      start: filterState.customStartDate ??
          DateTime.now().subtract(const Duration(days: 7)),
      end: filterState.customEndDate ?? DateTime.now(),
    );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: initialRange,
      helpText: 'Select Custom Returns Date Range',
    );

    if (picked != null) {
      ref
          .read(
              stitchingLedgerFilterProvider(_effectiveStitchingUserId).notifier)
          .setDateFilter(
            LedgerDateFilter.custom,
            customStart: picked.start,
            customEnd: picked.end,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authStateChangesProvider).value;
    final isAdmin = authUser?.role == UserRole.admin;

    final filterState =
        ref.watch(stitchingLedgerFilterProvider(_effectiveStitchingUserId));
    final filterNotifier = ref.read(
        stitchingLedgerFilterProvider(_effectiveStitchingUserId).notifier);

    final ledgerAsync =
        ref.watch(dayWiseStitchingLedgerProvider(_effectiveStitchingUserId));
    final usersAsync = ref.watch(stitchingUsersListProvider);
    final stitchingUsers = usersAsync.asData?.value ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Production Returns Ledger'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Custom Date Range',
            onPressed: () => _selectCustomDateRange(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Admin Stitching Unit Selector Dropdown
                if (isAdmin) ...[
                  Row(
                    children: [
                      const Icon(Icons.people_outline,
                          size: 18, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          value: filterState.stitchingUserId,
                          isDense: true,
                          decoration: const InputDecoration(
                            labelText: 'Filter by Stitching Unit',
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('All Stitching Units (Company Wide)'),
                            ),
                            ...stitchingUsers.map((u) => DropdownMenuItem(
                                  value: u.stitchingUserId,
                                  child: Text(u.name),
                                )),
                          ],
                          onChanged: (id) =>
                              filterNotifier.setStitchingUser(id),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                ],

                // Date Presets
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: LedgerDateFilter.availableFilters(isAdmin: isAdmin)
                        .map((preset) {
                      final isSelected = filterState.dateFilter == preset;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(preset.displayName),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (preset == LedgerDateFilter.custom) {
                              _selectCustomDateRange(context);
                            } else {
                              filterNotifier.setDateFilter(preset);
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (filterState.dateFilter == LedgerDateFilter.custom &&
                    filterState.customStartDate != null &&
                    filterState.customEndDate != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(
                        'Range: ${DateFormat('dd MMM yyyy').format(filterState.customStartDate!)} - ${DateFormat('dd MMM yyyy').format(filterState.customEndDate!)}',
                        style: TextStyle(
                            fontSize: 12, color: theme.colorScheme.primary),
                      ),
                      TextButton(
                        onPressed: () => _selectCustomDateRange(context),
                        child: const Text('Change',
                            style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Ledger Content
          Expanded(
            child: ledgerAsync.when(
              loading: () => const LoadingView(
                  message: 'Calculating production returns...'),
              error: (err, _) => ErrorView(
                message: err.toString(),
                onRetry: () => ref.invalidate(
                    dayWiseStitchingLedgerProvider(_effectiveStitchingUserId)),
              ),
              data: (dayWiseLedgers) {
                if (dayWiseLedgers.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.assignment_turned_in_outlined,
                            size: 56, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'No Production Returns Found',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'No return transactions match the selected date & unit filter.',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                // Overall Totals
                var overallReturned = 0.0;
                var overallEvents = 0;
                final allChallans = <String>{};

                for (final day in dayWiseLedgers) {
                  overallReturned += day.totalReturnedQuantity;
                  overallEvents += day.totalEvents;
                  for (final dist in day.distributions) {
                    allChallans.add(dist.challanId);
                  }
                }

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Summary KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: _StitchingSummaryCard(
                            label: 'Finished Sarees Returned',
                            value: overallReturned.toInt().toString(),
                            color: Colors.green.shade800,
                            icon: Icons.checkroom,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StitchingSummaryCard(
                            label: 'Return Events',
                            value: overallEvents.toString(),
                            color: Colors.indigo.shade700,
                            icon: Icons.event_available,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _StitchingSummaryCard(
                            label: 'Challans Settled',
                            value: allChallans.length.toString(),
                            color: Colors.teal.shade700,
                            icon: Icons.receipt_long,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Day-Wise Production Returns',
                          style: theme.textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '${dayWiseLedgers.length} Active Days',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Day-Wise Cards List
                    ...dayWiseLedgers.map((dayLedger) {
                      return _DayWiseStitchingCard(dayLedger: dayLedger);
                    }),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _DayWiseStitchingCard extends StatelessWidget {
  const _DayWiseStitchingCard({required this.dayLedger});

  final DayWiseStitchingLedger dayLedger;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final isToday = dayLedger.date.year == now.year &&
        dayLedger.date.month == now.month &&
        dayLedger.date.day == now.day;
    final dateStr = DateFormat('EEEE, dd MMMM yyyy').format(dayLedger.date);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        initiallyExpanded: isToday,
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              isToday ? Colors.green.shade700 : Colors.grey.shade200,
          foregroundColor: isToday ? Colors.white : Colors.black87,
          child: Text(
            '${dayLedger.date.day}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                dateStr,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'TODAY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 6,
            runSpacing: 4,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  '+${dayLedger.totalReturnedQuantity.toInt()} Sarees Returned',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Text(
                  '${dayLedger.uniqueChallansCount} Challan${dayLedger.uniqueChallansCount > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo.shade800,
                  ),
                ),
              ),
            ],
          ),
        ),
        children: [
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.all(12),
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Returned Sarees Distribution (${dayLedger.distributions.length} records)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const Text(
                      'Tap challan to view details',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Distribution line items
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: dayLedger.distributions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, idx) {
                    final dist = dayLedger.distributions[idx];
                    final timeStr =
                        DateFormat('hh:mm a').format(dist.timestamp);

                    return Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Backlink to Challan Details
                              InkWell(
                                onTap: () => ChallanDetailByIdScreen.navigate(
                                  context,
                                  dist.challanId,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                        color: Colors.indigo.shade300),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.open_in_new,
                                          size: 13,
                                          color: Colors.indigo.shade900),
                                      const SizedBox(width: 4),
                                      Text(
                                        dist.challanNumber,
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Colors.indigo.shade900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              Text(
                                timeStr,
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${dist.productName} (${dist.sku})',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13),
                                    ),
                                    Text(
                                      'Unit: ${dist.stitchingUserName}',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey.shade700),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade50,
                                  borderRadius: BorderRadius.circular(6),
                                  border:
                                      Border.all(color: Colors.green.shade300),
                                ),
                                child: Text(
                                  '+${dist.quantity.toInt()} Sarees Returned',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (dist.notes != null && dist.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Notes: ${dist.notes}',
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StitchingSummaryCard extends StatelessWidget {
  const _StitchingSummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

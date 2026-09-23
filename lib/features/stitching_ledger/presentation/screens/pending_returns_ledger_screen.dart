import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:saree_sutra/core/enums/user_role.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/auth/presentation/controllers/auth_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_by_id_screen.dart';
import 'package:saree_sutra/features/deposit_requests/presentation/widgets/create_deposit_request_dialog.dart';
import 'package:saree_sutra/features/stitching_ledger/domain/pending_returns_ledger_models.dart';
import 'package:saree_sutra/features/stitching_ledger/presentation/controllers/pending_returns_ledger_providers.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';

/// Screen presenting the Pending Products to Return Ledger.
/// Allows stitching users to see which products and quantities they still owe,
/// and allows admins to see user-wise and product-wise outstanding balances.
class PendingReturnsLedgerScreen extends ConsumerStatefulWidget {
  const PendingReturnsLedgerScreen({super.key, this.initialStitchingUserId});

  final String? initialStitchingUserId;

  @override
  ConsumerState<PendingReturnsLedgerScreen> createState() =>
      _PendingReturnsLedgerScreenState();
}

class _PendingReturnsLedgerScreenState
    extends ConsumerState<PendingReturnsLedgerScreen> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  String? _selectedUserId;

  @override
  void initState() {
    super.initState();
    _selectedUserId = widget.initialStitchingUserId;
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authUser = ref.watch(authStateChangesProvider).value;
    final isAdmin = authUser?.role == UserRole.admin;

    final effectiveUserFilter =
        isAdmin ? _selectedUserId : authUser?.stitchingUserId;
    final ledgerAsync =
        ref.watch(pendingReturnsLedgerDataProvider(effectiveUserFilter));
    final usersAsync = ref.watch(stitchingUsersListProvider);
    final stitchingUsers = usersAsync.asData?.value ?? [];

    return DefaultTabController(
      length: isAdmin ? 3 : 2,
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAdmin
                    ? 'Pending Products to Return'
                    : 'My Pending Products to Return',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              Text(
                isAdmin
                    ? 'User-wise and product-wise outstanding stitching stock'
                    : 'Finished sarees remaining to stitch and return',
                style: TextStyle(
                  fontSize: 12,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          bottom: TabBar(
            tabs: isAdmin
                ? const [
                    Tab(
                        icon: Icon(Icons.people_outline),
                        text: 'By Stitching Unit'),
                    Tab(
                        icon: Icon(Icons.inventory_2_outlined),
                        text: 'By Product'),
                    Tab(
                        icon: Icon(Icons.receipt_long_outlined),
                        text: 'By Challan'),
                  ]
                : const [
                    Tab(
                        icon: Icon(Icons.inventory_2_outlined),
                        text: 'By Product'),
                    Tab(
                        icon: Icon(Icons.receipt_long_outlined),
                        text: 'By Challan'),
                  ],
          ),
        ),
        body: ledgerAsync.when(
          loading: () =>
              const LoadingView(message: 'Calculating pending return stock...'),
          error: (err, stack) => ErrorView(
            message: 'Failed to load pending returns data: $err',
            onRetry: () => ref.invalidate(
              pendingReturnsLedgerDataProvider(effectiveUserFilter),
            ),
          ),
          data: (ledgerData) {
            return Column(
              children: [
                // Admin: Stitching Unit Dropdown Filter
                if (isAdmin)
                  _buildAdminUnitSelector(
                      stitchingUsers, ledgerData.userSummaries),

                // KPI Summary Banner
                _buildKpiBanner(theme, ledgerData, isAdmin),

                // Search Bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: isAdmin
                          ? 'Search unit name, product, SKU, or challan #...'
                          : 'Search product, SKU, or challan #...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => _searchCtrl.clear(),
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      isDense: true,
                    ),
                  ),
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    children: isAdmin
                        ? [
                            // Tab 1: By Stitching Unit (User-Wise)
                            _buildUserWiseList(
                              theme,
                              ledgerData.userSummaries,
                            ),
                          // Tab 2: By Product
                          _buildProductWiseList(
                            theme,
                            ledgerData.productSummaries,
                            showUserBreakdown: true,
                            isStitchingUser: false,
                          ),
                          // Tab 3: By Challan
                          _buildChallanWiseList(
                            theme,
                            ledgerData.allItems,
                            showUserName: true,
                          ),
                        ]
                      : [
                          // Tab 1: By Product (Stitching User)
                          _buildProductWiseList(
                            theme,
                            ledgerData.productSummaries,
                            showUserBreakdown: false,
                            isStitchingUser: true,
                            stitchingUserId: authUser?.stitchingUserId,
                          ),
                          // Tab 2: By Challan
                          _buildChallanWiseList(
                            theme,
                            ledgerData.allItems,
                            showUserName: false,
                          ),
                        ],
                ),
              ),
            ],
          );
        },
      ),
    ),
  );
  }

  Widget _buildAdminUnitSelector(
    List<dynamic> users,
    List<UserPendingReturn> userSummaries,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.grey.shade50,
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          const Text(
            'Unit Filter:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String?>(
                isExpanded: true,
                value: _selectedUserId,
                hint: const Text('All Stitching Units'),
                items: [
                  const DropdownMenuItem<String?>(
                    value: null,
                    child: Text('All Stitching Units (Company Total)'),
                  ),
                  ...users.map((u) {
                    final hasPending = userSummaries
                        .any((s) => s.stitchingUserId == u.stitchingUserId);
                    return DropdownMenuItem<String?>(
                      value: u.stitchingUserId as String,
                      child: Text(
                        '${u.name}${hasPending ? ' (Has Pending Stock)' : ''}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedUserId = val;
                  });
                },
              ),
            ),
          ),
          if (_selectedUserId != null)
            TextButton(
              onPressed: () => setState(() => _selectedUserId = null),
              child: const Text('Reset', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
    );
  }

  Widget _buildKpiBanner(
    ThemeData theme,
    PendingReturnsLedgerData data,
    bool isAdmin,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time_filled,
                        size: 16, color: Colors.purple.shade700),
                    const SizedBox(width: 6),
                    Text(
                      'TOTAL PENDING TO RETURN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.totalPending.toInt()} pcs',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Issued: ${data.totalIssued.toInt()} | Returned: ${data.totalReturned.toInt()}',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.purple.shade800,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 50,
            width: 1,
            color: Colors.purple.shade200,
            margin: const EdgeInsets.symmetric(horizontal: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.category,
                        size: 16, color: Colors.deepPurple.shade700),
                    const SizedBox(width: 6),
                    Text(
                      isAdmin ? 'ACTIVE SCOPE' : 'VARIETIES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple.shade900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '${data.uniqueProductsCount} Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isAdmin
                      ? '${data.activeUsersCount} Units | ${data.activeChallansCount} Challans'
                      : 'Across ${data.activeChallansCount} Challans',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.deepPurple.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================================================================
  // TAB 1: User-Wise (Stitching Unit) List for Admin
  // =========================================================================
  Widget _buildUserWiseList(ThemeData theme, List<UserPendingReturn> users) {
    var filtered = users;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((u) {
        final matchesUser = u.userName.toLowerCase().contains(_searchQuery) ||
            (u.userPhone?.toLowerCase().contains(_searchQuery) ?? false);
        final matchesProduct = u.products.any((p) =>
            p.productName.toLowerCase().contains(_searchQuery) ||
            p.sku.toLowerCase().contains(_searchQuery) ||
            (p.color?.toLowerCase().contains(_searchQuery) ?? false));
        return matchesUser || matchesProduct;
      }).toList();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(
        theme,
        title: 'No User Shortages Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No stitching units match your search query.'
            : 'All stitching units have fully returned their finished sarees!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final user = filtered[index];
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            shape: const Border(),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: Icon(Icons.storefront, color: Colors.teal.shade800),
            ),
            title: Text(
              user.userName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            subtitle: Row(
              children: [
                if (user.userPhone != null && user.userPhone!.isNotEmpty) ...[
                  Text(user.userPhone!,
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 8),
                ],
                Text(
                  '${user.products.length} Products | ${user.items.length} Challan lines',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Text(
                '${user.totalPending.toInt()} pending',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Colors.purple.shade900,
                ),
              ),
            ),
            children: [
              const Divider(height: 1),
              Container(
                color: Colors.grey.shade50,
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Outstanding Products at ${user.userName}:',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...user.products.map((prod) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    prod.productName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    '${prod.totalPending.toInt()} pcs pending',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.red.shade800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text('SKU: ${prod.sku}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade700)),
                                if (prod.color != null) ...[
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      prod.color!,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.purple.shade800,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                                const Spacer(),
                                Text(
                                  'Issued: ${prod.totalIssued.toInt()} | Returned: ${prod.totalReturned.toInt()}',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: prod.items.map((it) {
                                return ActionChip(
                                  avatar: const Icon(Icons.receipt, size: 14),
                                  label: Text(
                                    '${it.challanNumber} (${it.pendingQuantity.toInt()} pending)',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  onPressed: () =>
                                      ChallanDetailByIdScreen.navigate(
                                    context,
                                    it.challanId,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 2: Product-Wise List
  // =========================================================================
  Widget _buildProductWiseList(
    ThemeData theme,
    List<ProductPendingReturn> products, {
    required bool showUserBreakdown,
    required bool isStitchingUser,
    String? stitchingUserId,
  }) {
    var filtered = products;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) {
        final matchesProduct =
            p.productName.toLowerCase().contains(_searchQuery) ||
                p.sku.toLowerCase().contains(_searchQuery) ||
                (p.color?.toLowerCase().contains(_searchQuery) ?? false);
        final matchesChallan = p.items
            .any((it) => it.challanNumber.toLowerCase().contains(_searchQuery));
        final matchesUser = p.items.any(
            (it) => it.stitchingUserName.toLowerCase().contains(_searchQuery));
        return matchesProduct || matchesChallan || matchesUser;
      }).toList();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(
        theme,
        title: 'No Pending Products Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No products match your search query.'
            : 'All issued sarees for these products have been fully returned!',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final prod = filtered[index];
        final returnProgress = prod.totalIssued > 0
            ? (prod.totalReturned / prod.totalIssued).clamp(0.0, 1.0)
            : 0.0;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Product name & total pending badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: theme.colorScheme.primaryContainer,
                      child: Icon(
                        Icons.checkroom,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            prod.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  'SKU: ${prod.sku}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              if (prod.color != null &&
                                  prod.color!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.purple.shade50,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                        color: Colors.purple.shade200),
                                  ),
                                  child: Text(
                                    prod.color!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.purple.shade800,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${prod.totalPending.toInt()} pcs',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade800,
                            ),
                          ),
                          Text(
                            'Pending Return',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Quantities Row & Progress bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Issued: ${prod.totalIssued.toInt()} pcs',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      'Total Returned: ${prod.totalReturned.toInt()} pcs (${(returnProgress * 100).toInt()}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: returnProgress,
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade200,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.green.shade600),
                  ),
                ),
                const SizedBox(height: 14),

                // Admin: User Breakdown chips (which unit owes how many)
                if (showUserBreakdown && prod.userPendingMap.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Units Holding This Product:',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueGrey,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: prod.items
                              .map((it) => it.stitchingUserName)
                              .toSet()
                              .map((uName) {
                            final userPending = prod.items
                                .where((it) => it.stitchingUserName == uName)
                                .fold<double>(
                                    0, (sum, it) => sum + it.pendingQuantity);
                            return Chip(
                              backgroundColor: Colors.white,
                              visualDensity: VisualDensity.compact,
                              avatar: const Icon(Icons.storefront, size: 14),
                              label: Text(
                                '$uName: ${userPending.toInt()} pcs',
                                style: const TextStyle(fontSize: 11),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Challans Breakdown List
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Challan Line Breakdowns (${prod.items.length}):',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ...prod.items.map((it) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => ChallanDetailByIdScreen.navigate(
                                  context,
                                  it.challanId,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        it.challanNumber,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: theme
                                              .colorScheme.onPrimaryContainer,
                                        ),
                                      ),
                                      const SizedBox(width: 2),
                                      Icon(
                                        Icons.open_in_new,
                                        size: 10,
                                        color: theme
                                            .colorScheme.onPrimaryContainer,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              if (showUserBreakdown) ...[
                                Expanded(
                                  child: Text(
                                    it.stitchingUserName,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ] else ...[
                                Expanded(
                                  child: Text(
                                    DateFormat('dd MMM yyyy')
                                        .format(it.issuedAt),
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ),
                              ],
                              Text(
                                'Issued: ${it.issuedQuantity.toInt()}',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade700,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pending: ${it.pendingQuantity.toInt()}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),

                // Stitching User Action: Submit Return for this Product
                if (isStitchingUser && stitchingUserId != null) ...[
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => CreateDepositRequestDialog(
                            stitchingUserId: stitchingUserId,
                            initialProductId: prod.productId,
                            initialSku: prod.sku,
                          ),
                        );
                      },
                      icon: const Icon(Icons.assignment_return, size: 16),
                      label: const Text('Return This Product'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // =========================================================================
  // TAB 3: Challan-Wise Granular List
  // =========================================================================
  Widget _buildChallanWiseList(
    ThemeData theme,
    List<PendingReturnChallanItem> items, {
    required bool showUserName,
  }) {
    var filtered = items;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((it) {
        final matchesChallan =
            it.challanNumber.toLowerCase().contains(_searchQuery);
        final matchesProduct =
            it.productName.toLowerCase().contains(_searchQuery) ||
                it.sku.toLowerCase().contains(_searchQuery) ||
                (it.color?.toLowerCase().contains(_searchQuery) ?? false);
        final matchesUser =
            it.stitchingUserName.toLowerCase().contains(_searchQuery);
        return matchesChallan || matchesProduct || matchesUser;
      }).toList();
    }

    if (filtered.isEmpty) {
      return _buildEmptyState(
        theme,
        title: 'No Pending Challans Found',
        subtitle: _searchQuery.isNotEmpty
            ? 'No challans match your search query.'
            : 'All challan production orders are 100% completed and returned!',
      );
    }

    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final it = filtered[index];
        return Card(
          elevation: 1.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () => ChallanDetailByIdScreen.navigate(
                          context, it.challanId),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.receipt_long,
                              size: 14,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              it.challanNumber,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward,
                              size: 12,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Text(
                      dateFormat.format(it.issuedAt),
                      style:
                          TextStyle(fontSize: 11, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (showUserName) ...[
                  Row(
                    children: [
                      Icon(Icons.storefront,
                          size: 14, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Text(
                        'Assigned Unit: ',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade600),
                      ),
                      Text(
                        it.stitchingUserName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        it.productName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Text(
                      '${it.pendingQuantity.toInt()} Sarees Pending',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('SKU: ${it.sku}',
                        style: TextStyle(
                            fontSize: 11, color: Colors.grey.shade700)),
                    if (it.color != null && it.color!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Text('(${it.color})',
                          style: TextStyle(
                              fontSize: 11, color: Colors.purple.shade700)),
                    ],
                    const Spacer(),
                    Text(
                      'Issued: ${it.issuedQuantity.toInt()} | Returned: ${it.returnedQuantity.toInt()}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    ThemeData theme, {
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Colors.green.shade100,
              child: const Icon(
                Icons.check_circle_outline,
                size: 40,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

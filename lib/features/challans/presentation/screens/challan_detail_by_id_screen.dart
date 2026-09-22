import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/features/challans/presentation/controllers/challan_providers.dart';
import 'package:saree_sutra/features/challans/presentation/screens/challan_detail_screen.dart';

/// Screen that loads a Challan by its ID and delegates to [ChallanDetailScreen].
/// This powers direct backlinks from ledgers and audit logs.
class ChallanDetailByIdScreen extends ConsumerWidget {
  const ChallanDetailByIdScreen({super.key, required this.challanId});

  final String challanId;

  static void navigate(BuildContext context, String challanId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChallanDetailByIdScreen(challanId: challanId),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final challanAsync = ref.watch(challanStreamProvider(challanId));

    return challanAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Loading Challan...')),
        body: const LoadingView(message: 'Fetching challan details...'),
      ),
      error: (err, _) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(challanStreamProvider(challanId)),
        ),
      ),
      data: (challan) => ChallanDetailScreen(challan: challan),
    );
  }
}

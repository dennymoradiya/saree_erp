import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:saree_sutra/core/widgets/async_state_widgets.dart';
import 'package:saree_sutra/core/widgets/status_badge.dart';
import 'package:saree_sutra/features/users/presentation/controllers/users_providers.dart';
import 'package:saree_sutra/features/users/presentation/widgets/created_account_dialog.dart';

class StitchingUsersScreen extends ConsumerWidget {
  const StitchingUsersScreen({super.key});

  void _openAddStitchingUserDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const _AddStitchingUserDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stitchingUsersAsync = ref.watch(stitchingUsersListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stitching Users'),
      ),
      body: stitchingUsersAsync.when(
        data: (stitchingUsers) {
          if (stitchingUsers.isEmpty) {
            return const EmptyView(
              message:
                  'No stitching users added yet. Tap + to add the first one.',
              icon: Icons.people_outline,
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: stitchingUsers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final user = stitchingUsers[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(context)
                        .colorScheme
                        .outlineVariant
                        .withValues(alpha: 0.6),
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withValues(alpha: 0.7),
                    child: Text(
                      user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  title: Text(
                    user.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      if (user.phone != null && user.phone!.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.phone, size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(user.phone!),
                          ],
                        ),
                      ] else ...[
                        const Text(
                          'No phone recorded',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                      if (user.address != null &&
                          user.address!.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 14,
                              color: Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                user.address!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                  trailing: StatusBadge.active(user.isActive),
                ),
              );
            },
          );
        },
        loading: () => const LoadingView(message: 'Loading stitching users...'),
        error: (err, _) => ErrorView(
          message: err.toString(),
          onRetry: () => ref.invalidate(stitchingUsersListProvider),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddStitchingUserDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Stitching User'),
      ),
    );
  }
}

class _AddStitchingUserDialog extends ConsumerStatefulWidget {
  const _AddStitchingUserDialog();

  @override
  ConsumerState<_AddStitchingUserDialog> createState() =>
      _AddStitchingUserDialogState();
}

class _AddStitchingUserDialogState
    extends ConsumerState<_AddStitchingUserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final info = await ref
        .read(stitchingUserControllerProvider.notifier)
        .createStitchingUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (info != null) {
      Navigator.of(context).pop(); // Dismiss form dialog
      await showCreatedAccountDialog(
        context,
        accountType: 'Stitching User',
        accountInfo: info,
      );
    } else {
      final error = ref.read(stitchingUserControllerProvider).asError?.error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error?.toString() ?? 'Failed to create stitching user account.',
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Stitching User'),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Creates a stitching user profile and an associated login account with a generated temporary password.',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Full name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    hintText: 'used for account login',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number (Optional)',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Workshop / Home Address (Optional)',
                    prefixIcon: Icon(Icons.location_on_outlined),
                    border: OutlineInputBorder(),
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
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSubmitting ? null : _submit,
          child: _isSubmitting
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create Stitching User'),
        ),
      ],
    );
  }
}

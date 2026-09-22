import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:saree_sutra/features/users/domain/created_account_info.dart';

/// Shows a non-dismissible dialog containing the newly created user's
/// email and temporary password. Once dismissed, the password can never
/// be retrieved again from Firebase Auth.
Future<void> showCreatedAccountDialog(
  BuildContext context, {
  required String accountType,
  required CreatedAccountInfo accountInfo,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return PopScope(
        canPop: false,
        child: AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 44,
          ),
          title: Text('$accountType Account Created'),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.amber.shade900,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Copy this temporary password now. It is shown only once and cannot be retrieved later.',
                            style: TextStyle(
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _CredentialTile(
                    label: 'Email / Username',
                    value: accountInfo.email,
                    icon: Icons.email_outlined,
                  ),
                  const SizedBox(height: 12),
                  _CredentialTile(
                    label: 'Temporary Password',
                    value: accountInfo.temporaryPassword,
                    icon: Icons.key_outlined,
                    isMonospace: true,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('Copy WhatsApp Message'),
                    onPressed: () {
                      final message =
                          'Saree Sutra Login Details\n'
                          'Role: $accountType\n'
                          'Email: ${accountInfo.email}\n'
                          'Temporary Password: ${accountInfo.temporaryPassword}\n\n'
                          'Please log in and change your password upon first login.';
                      Clipboard.setData(ClipboardData(text: message));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Login details copied to clipboard for WhatsApp!',
                          ),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('I Have Saved This Password'),
            ),
          ],
        ),
      );
    },
  );
}

class _CredentialTile extends StatelessWidget {
  const _CredentialTile({
    required this.label,
    required this.value,
    required this.icon,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                SelectableText(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontFamily: isMonospace ? 'monospace' : null,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            tooltip: 'Copy $label',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('$label copied to clipboard'),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

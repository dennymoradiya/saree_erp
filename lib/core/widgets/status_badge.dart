import 'package:flutter/material.dart';
import 'package:saree_sutra/core/enums/challan_status.dart';
import 'package:saree_sutra/core/enums/deposit_request_status.dart';
import 'package:saree_sutra/core/theme/app_colors.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.label, required this.color, super.key});

  factory StatusBadge.challan(ChallanStatus status) {
    final (label, color) = switch (status) {
      ChallanStatus.draft => ('Draft', AppColors.statusDraft),
      ChallanStatus.issued => ('Issued', AppColors.stitchingPending),
      ChallanStatus.partiallyCompleted => ('Partial', AppColors.statusPartial),
      ChallanStatus.completed => ('Completed', AppColors.statusCompleted),
      ChallanStatus.cancelled => ('Cancelled', AppColors.statusCancelled),
    };
    return StatusBadge(label: label, color: color);
  }

  factory StatusBadge.depositRequest(DepositRequestStatus status) {
    final (label, color) = switch (status) {
      DepositRequestStatus.pending => ('Pending', AppColors.statusPending),
      DepositRequestStatus.approved => ('Approved', AppColors.statusCompleted),
      DepositRequestStatus.rejected => ('Rejected', AppColors.statusRejected),
      DepositRequestStatus.cancelled => (
          'Cancelled',
          AppColors.statusCancelled
        ),
    };
    return StatusBadge(label: label, color: color);
  }

  factory StatusBadge.active(bool isActive) {
    return StatusBadge(
      label: isActive ? 'Active' : 'Inactive',
      color: isActive ? AppColors.statusCompleted : AppColors.statusCancelled,
    );
  }

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final bool compact;

  const StatusBadge({super.key, required this.status, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final (color, label) = _statusInfo(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 9 : 11,
        vertical: compact ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: compact ? 5 : 6,
            height: compact ? 5 : 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: compact ? 6 : 7),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: compact ? 11 : 12,
              fontWeight: FontWeight.w700,
              fontFamily: AppTypography.body,
            ),
          ),
        ],
      ),
    );
  }

  (Color, String) _statusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'paid':
      case 'completed':
      case 'won':
      case 'resolved':
      case 'closed':
        return (AppColors.success, _label(status));
      case 'pending':
      case 'review':
      case 'contacted':
      case 'proposal':
      case 'negotiation':
      case 'in_progress':
      case 'expiring':
        return (AppColors.warning, _label(status));
      case 'overdue':
      case 'expired':
      case 'cancelled':
      case 'lost':
      case 'urgent':
        return (AppColors.danger, _label(status));
      case 'open':
      case 'new':
      case 'draft':
      case 'planning':
        return (AppColors.info, _label(status));
      case 'inactive':
      case 'on_hold':
      case 'low':
        return (AppColors.textMuted, _label(status));
      case 'medium':
      case 'high':
        return (AppColors.warning, _label(status));
      default:
        return (AppColors.textSecondary, _label(status));
    }
  }

  String _label(String status) {
    return status.replaceAll('_', ' ').split(' ').map((w) {
      if (w.isEmpty) return w;
      return '${w[0].toUpperCase()}${w.substring(1)}';
    }).join(' ');
  }
}

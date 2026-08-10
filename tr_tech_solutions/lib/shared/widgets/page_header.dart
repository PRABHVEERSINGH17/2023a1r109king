import 'package:flutter/material.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';

class PageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? eyebrow;
  final Widget? action;

  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.eyebrow,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final narrow = AppBreakpoints.isPhone(context);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          (eyebrow ?? 'TR Tech Solutions').toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            color: AppColors.primary,
            fontFamily: AppTypography.body,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: narrow ? 26 : 32,
            fontWeight: FontWeight.w700,
            fontFamily: AppTypography.display,
            letterSpacing: -1.0,
            color: AppColors.textPrimary,
            height: 1.05,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Text(
              subtitle!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontFamily: AppTypography.body,
                height: 1.45,
                fontSize: 14.5,
              ),
            ),
          ),
        ],
        const SizedBox(height: 14),
        Container(
          width: 42,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryLight],
            ),
          ),
        ),
      ],
    );

    if (action == null) return titleBlock;

    // On phones, stack actions under the title to avoid horizontal overflow.
    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleBlock,
          const SizedBox(height: 14),
          Align(alignment: Alignment.centerLeft, child: action!),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: titleBlock),
        const SizedBox(width: 12),
        Flexible(child: Align(alignment: Alignment.topRight, child: action!)),
      ],
    );
  }
}

class DataListCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const DataListCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(8),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.panelGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withOpacity(0.9)),
      ),
      padding: padding,
      child: child,
    );
  }
}

/// Soft interactive surface used for list rows and module tiles.
class SoftTile extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? tint;

  const SoftTile({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.tint,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        mouseCursor: onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            color: tint ?? AppColors.surface,
            border: Border.all(color: AppColors.border.withOpacity(0.85)),
            gradient: tint == null
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: AppColors.panelGradient,
                  )
                : null,
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}

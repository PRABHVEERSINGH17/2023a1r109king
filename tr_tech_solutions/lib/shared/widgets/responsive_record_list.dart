import 'package:flutter/material.dart';
import 'package:tr_tech_solutions/core/theme/app_breakpoints.dart';
import 'package:tr_tech_solutions/core/theme/app_colors.dart';
import 'package:tr_tech_solutions/core/theme/app_typography.dart';
import 'package:tr_tech_solutions/shared/widgets/page_header.dart';

/// On phones shows a vertical card list; on larger screens shows [table].
class ResponsiveRecordList extends StatelessWidget {
  final Widget table;
  final Widget list;

  const ResponsiveRecordList({
    super.key,
    required this.table,
    required this.list,
  });

  @override
  Widget build(BuildContext context) {
    if (AppBreakpoints.isPhone(context)) {
      return list;
    }
    return DataListCard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: table,
      ),
    );
  }
}

/// Compact record row used on phone layouts instead of DataTable.
class MobileRecordTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? badge;
  final List<Widget> actions;

  const MobileRecordTile({
    super.key,
    required this.title,
    this.subtitle,
    this.badge,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    return SoftTile(
      padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontFamily: AppTypography.display,
                    fontSize: 15.5,
                    letterSpacing: -0.2,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null && subtitle!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontFamily: AppTypography.body,
                      fontSize: 12.5,
                      height: 1.35,
                    ),
                  ),
                ],
                if (badge != null) ...[
                  const SizedBox(height: 8),
                  badge!,
                ],
              ],
            ),
          ),
          if (actions.isNotEmpty)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: actions,
            ),
        ],
      ),
    );
  }
}

/// Scrollable dialog body that fits phone widths.
Widget responsiveDialogBody(BuildContext context, {required Widget child}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      maxWidth: AppBreakpoints.dialogMaxWidth(context),
      maxHeight: MediaQuery.sizeOf(context).height * 0.65,
    ),
    child: SingleChildScrollView(child: child),
  );
}

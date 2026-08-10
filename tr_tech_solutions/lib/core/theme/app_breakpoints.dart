import 'package:flutter/material.dart';

/// Shared mobile layout helpers to avoid overflow on small phones.
class AppBreakpoints {
  static bool isPhone(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 600;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 400;

  static EdgeInsets pagePadding(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w < 400) return const EdgeInsets.fromLTRB(14, 14, 14, 20);
    if (w < 600) return const EdgeInsets.fromLTRB(16, 16, 16, 22);
    return const EdgeInsets.all(24);
  }

  static double dialogMaxWidth(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w - 40).clamp(260.0, 420.0);
  }
}

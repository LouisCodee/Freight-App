import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Visual status chip matching Stitch "Status Chips" component spec.
/// Uses pill shape with 10% opacity background of the status color.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.status = ChipStatus.info,
    this.dotSize = 6.0,
    this.showDot = true,
  });

  final String label;
  final ChipStatus status;
  final double dotSize;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final colors = _resolveColors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: colors.$2,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: colors.$1,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colors.$1,
            ),
          ),
        ],
      ),
    );
  }

  (Color, Color) _resolveColors() {
    return switch (status) {
      ChipStatus.success => (AppTheme.statusGreen, AppTheme.statusGreenContainer),
      ChipStatus.warning => (AppTheme.statusAmber, AppTheme.statusAmberContainer),
      ChipStatus.error => (AppTheme.statusRed, AppTheme.statusRedContainer),
      ChipStatus.info => (AppTheme.statusBlue, AppTheme.statusBlueContainer),
      ChipStatus.primary => (AppTheme.primaryColor, AppTheme.primaryContainer.withValues(alpha: 0.15)),
      ChipStatus.orange => (AppTheme.secondaryColor, AppTheme.secondaryContainer.withValues(alpha: 0.15)),
    };
  }
}

enum ChipStatus { success, warning, error, info, primary, orange }

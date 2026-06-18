import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Route-string component: origin → destination connected by a vertical
/// thread with dots at each end. Matches Stitch "Route-String" component spec.
class RouteString extends StatelessWidget {
  const RouteString({
    super.key,
    required this.origin,
    required this.destination,
    this.originLabel,
    this.destinationLabel,
    this.lineColor = AppTheme.outlineVariant,
    this.lineHeight = 28.0,
  });

  final String origin;
  final String destination;
  final String? originLabel;
  final String? destinationLabel;
  final Color lineColor;
  final double lineHeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Thread column
        Column(
          children: [
            _Dot(color: AppTheme.primaryColor, filled: true),
            _DashedLine(height: lineHeight, color: lineColor),
            _Dot(color: AppTheme.secondaryContainer, filled: true),
          ],
        ),
        const SizedBox(width: 12),
        // Text column
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (originLabel != null)
                Text(
                  originLabel!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              Text(
                origin,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
              SizedBox(height: lineHeight - 4),
              if (destinationLabel != null)
                Text(
                  destinationLabel!,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
              Text(
                destination,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.filled});
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : Colors.transparent,
        border: Border.all(color: color, width: 2),
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  const _DashedLine({required this.height, required this.color});
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 2,
      height: height,
      child: CustomPaint(painter: _DashedLinePainter(color: color)),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  const _DashedLinePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashHeight = 4.0;
    const dashSpace = 3.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

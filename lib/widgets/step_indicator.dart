import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Multi-step progress indicator with numbered circles + connecting lines.
/// Matches the Stitch Create Listing step progress design.
class StepIndicator extends StatelessWidget {
  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.stepLabels,
  });

  final int currentStep; // 1-indexed
  final int totalSteps;
  final List<String>? stepLabels;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (i) {
        if (i.isOdd) {
          // Connector line
          final stepIdx = (i ~/ 2) + 1;
          final isCompleted = stepIdx < currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 2,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.secondaryContainer
                    : AppTheme.outlineVariant,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        } else {
          // Step circle
          final stepNum = (i ~/ 2) + 1;
          return _StepCircle(
            stepNumber: stepNum,
            currentStep: currentStep,
            label: stepLabels != null && stepLabels!.length >= stepNum
                ? stepLabels![stepNum - 1]
                : null,
          );
        }
      }),
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({
    required this.stepNumber,
    required this.currentStep,
    this.label,
  });

  final int stepNumber;
  final int currentStep;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final isCompleted = stepNumber < currentStep;
    final isActive = stepNumber == currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? AppTheme.secondaryContainer
                : isActive
                    ? AppTheme.primaryColor
                    : AppTheme.surfaceContainer,
            border: Border.all(
              color: isCompleted
                  ? AppTheme.secondaryContainer
                  : isActive
                      ? AppTheme.primaryColor
                      : AppTheme.outlineVariant,
              width: 2,
            ),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
                : Text(
                    '$stepNumber',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        if (label != null) ...[
          const SizedBox(height: 6),
          Text(
            label!,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: isActive ? AppTheme.primaryColor : AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

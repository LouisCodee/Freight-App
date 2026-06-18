import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// Reusable immersive navy header used across all auth screens.
/// Replaces the default AppBar with a branded header.
class AuthHeader extends StatelessWidget {
  const AuthHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.badgeLabel,
    this.showLogo = false,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final String? badgeLabel;
  final bool showLogo;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/home/intermodal_train.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.8),
                  AppTheme.primaryColor,
                ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  AppTheme.spacingMd,
                  AppTheme.spacingXl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                  children: [
                    if (showBack)
                      _BackButton(onTap: () => Navigator.of(context).pop()),
                    if (showLogo && !showBack) ...[
                      _LogoMark(),
                      const SizedBox(width: AppTheme.spacingSm),
                    ],
                    const Spacer(),
                    if (badgeLabel != null) _BadgeChip(label: badgeLabel!),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingLg),
                if (showLogo && showBack) ...[
                  _LogoMark(),
                  const SizedBox(height: AppTheme.spacingMd),
                ],
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ],
  ),
);
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: const Icon(
          Icons.arrow_back_ios_new_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _LogoMark extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: const Icon(
        Icons.local_shipping_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppTheme.secondaryContainer.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.secondaryContainer.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../auth/role_selection_screen.dart';
import 'edit_profile_screen.dart';

class CargoShipperProfileScreen extends StatefulWidget {
  const CargoShipperProfileScreen({super.key});

  @override
  State<CargoShipperProfileScreen> createState() => _CargoShipperProfileScreenState();
}

class _CargoShipperProfileScreenState extends State<CargoShipperProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _ProfileHeader(),
                const SizedBox(height: 16),
                _AccountSettingsList(context, () => setState(() {})),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppTheme.surfaceContainerLowest,
      pinned: true,
      elevation: 0,
      centerTitle: true,
      title: const Text(
        'Company Profile',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: AppTheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: AuthService().getCurrentUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        return Container(
          color: AppTheme.surfaceContainerLowest,
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: Column(
            children: [
              Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor.withValues(alpha: 0.1),
                      border: Border.all(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.business_rounded,
                      size: 50,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                user?.name ?? 'Loading...',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Cargo Shipper · Dodoma',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatBadge(icon: Icons.inventory_2_rounded, value: '45 Shipments'),
                  const SizedBox(width: 12),
                  _StatBadge(icon: Icons.verified_rounded, value: 'Verified Business'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.icon, required this.value});
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryColor),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountSettingsList extends StatelessWidget {
  const _AccountSettingsList(this.context, this.onProfileUpdated);
  final BuildContext context;
  final VoidCallback onProfileUpdated;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Company Settings',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.business_outlined,
                  title: 'Company Information',
                  onTap: () async {
                    final user = await AuthService().getCurrentUser();
                    if (user != null && context.mounted) {
                      final updated = await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => EditProfileScreen(user: user)),
                      );
                      if (updated == true) {
                        onProfileUpdated();
                      }
                    }
                  },
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.verified_user_outlined,
                  title: 'Business Documents',
                  badge: 'Verified',
                  badgeColor: AppTheme.statusGreen,
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Payment Methods',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Activity & Support',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              children: [
                _SettingsTile(
                  icon: Icons.support_agent_rounded,
                  title: 'Help & Support',
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56),
                _SettingsTile(
                  icon: Icons.description_outlined,
                  title: 'Terms of Service',
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            textColor: AppTheme.statusRed,
            iconColor: AppTheme.statusRed,
            showArrow: false,
            onTap: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const RoleSelectionScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.badgeColor,
    this.textColor,
    this.iconColor,
    this.showArrow = true,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final Color? badgeColor;
  final Color? textColor;
  final Color? iconColor;
  final bool showArrow;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: textColor ?? AppTheme.onSurface,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (badgeColor ?? AppTheme.primaryColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: badgeColor ?? AppTheme.primaryColor,
                ),
              ),
            ),
          if (badge != null && showArrow) const SizedBox(width: 8),
          if (showArrow)
            const Icon(Icons.chevron_right_rounded,
                color: AppTheme.outline, size: 20),
        ],
      ),
    );
  }
}

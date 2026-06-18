import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverList(
            delegate: SliverChildListDelegate([
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Today',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
              _NotificationTile(
                title: 'New Booking Request',
                subtitle: 'Coastal Traders Ltd sent a request for Dar → Mwanza',
                time: '2m ago',
                icon: Icons.local_shipping_rounded,
                iconColor: AppTheme.statusBlue,
                isUnread: true,
              ),
              _NotificationTile(
                title: 'Payment Received',
                subtitle: 'TZS 850,000 has been credited to your account',
                time: '1h ago',
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppTheme.statusGreen,
                isUnread: true,
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Yesterday',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
              _NotificationTile(
                title: 'Trip Completed',
                subtitle: 'Trip #FR-8890 has been marked as completed',
                time: 'Yesterday',
                icon: Icons.check_circle_rounded,
                iconColor: AppTheme.primaryColor,
                isUnread: false,
              ),
              _NotificationTile(
                title: 'New Review',
                subtitle: 'You received a 5-star review from Apex Agri Ltd',
                time: 'Yesterday',
                icon: Icons.star_rounded,
                iconColor: AppTheme.secondaryColor,
                isUnread: false,
              ),
            ]),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppTheme.onSurface,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all_rounded, color: AppTheme.primaryColor),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.isUnread,
  });

  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool isUnread;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isUnread
          ? AppTheme.primaryColor.withValues(alpha: 0.05)
          : AppTheme.surfaceContainerLowest,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 15,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: AppTheme.onSurface,
                              ),
                            ),
                          ),
                          Text(
                            time,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: isUnread
                                  ? AppTheme.primaryColor
                                  : AppTheme.onSurfaceVariant,
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: AppTheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 68, color: AppTheme.outlineVariant),
        ],
      ),
    );
  }
}

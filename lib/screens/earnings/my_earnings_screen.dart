import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';

class MyEarningsScreen extends StatelessWidget {
  const MyEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainerLow,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TotalEarningsCard(),
                  const SizedBox(height: 24),
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _TransactionList(),
                ],
              ),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: AppTheme.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'My Earnings',
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
          icon: const Icon(Icons.filter_list_rounded,
              color: AppTheme.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}

class _TotalEarningsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Total Available Balance',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'TZS 2,450,000',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                  ),
                  icon: const Icon(Icons.account_balance_rounded, size: 18),
                  label: const Text(
                    'Withdraw',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransactionList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _TransactionItem(
            title: 'Trip #FR-8921 Completion',
            date: 'Oct 15, 2026',
            amount: '+ TZS 850,000',
            isPositive: true,
            status: ChipStatus.success,
          ),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          _TransactionItem(
            title: 'Withdrawal to Bank (...4567)',
            date: 'Oct 10, 2026',
            amount: '- TZS 1,200,000',
            isPositive: false,
            status: ChipStatus.info,
          ),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          _TransactionItem(
            title: 'Platform Fee Deduction',
            date: 'Oct 15, 2026',
            amount: '- TZS 42,500',
            isPositive: false,
            status: ChipStatus.warning,
          ),
          const Divider(height: 1, color: AppTheme.outlineVariant),
          _TransactionItem(
            title: 'Trip #FR-8890 Completion',
            date: 'Oct 02, 2026',
            amount: '+ TZS 600,000',
            isPositive: true,
            status: ChipStatus.success,
          ),
        ],
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  const _TransactionItem({
    required this.title,
    required this.date,
    required this.amount,
    required this.isPositive,
    required this.status,
  });

  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final ChipStatus status;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isPositive
                  ? AppTheme.statusGreenContainer
                  : AppTheme.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPositive
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: isPositive ? AppTheme.statusGreen : AppTheme.onSurfaceVariant,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isPositive ? AppTheme.statusGreen : AppTheme.onSurface,
                ),
              ),
              const SizedBox(height: 6),
              StatusChip(
                label: isPositive ? 'Completed' : 'Processed',
                status: status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

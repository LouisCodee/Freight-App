import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/status_chip.dart';
import '../../services/earnings_service.dart';
import '../../models/transaction_model.dart';

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
          StreamBuilder<double>(
            stream: EarningsService().getTotalBalance(),
            builder: (context, snapshot) {
              final balance = snapshot.data ?? 0.0;
              // Formatting simple since intl isn't added
              final formattedBalance = balance.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
              return Text(
                'TZS $formattedBalance',
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.5,
                ),
              );
            }
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
  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: StreamBuilder<List<TransactionModel>>(
        stream: EarningsService().getTransactions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final transactions = snapshot.data ?? [];
          if (transactions.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(
                child: Text(
                  'No transactions yet.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }

          return Column(
            children: transactions.asMap().entries.map((entry) {
              final index = entry.key;
              final tx = entry.value;
              
              final formattedAmount = tx.amount.toStringAsFixed(0).replaceAllMapped(
                RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                (Match m) => '${m[1]},',
              );
              final sign = tx.isPositive ? '+' : '-';

              ChipStatus chipStatus;
              switch (tx.status) {
                case TransactionStatus.pending: chipStatus = ChipStatus.warning; break;
                case TransactionStatus.failed: chipStatus = ChipStatus.error; break;
                case TransactionStatus.completed: 
                  chipStatus = tx.isPositive ? ChipStatus.success : ChipStatus.info; 
                  break;
              }

              return Column(
                children: [
                  _TransactionItem(
                    title: tx.title,
                    date: _formatDate(tx.date),
                    amount: '$sign TZS $formattedAmount',
                    isPositive: tx.isPositive,
                    status: chipStatus,
                    statusLabel: tx.status.toString().split('.').last,
                  ),
                  if (index < transactions.length - 1)
                    const Divider(height: 1, color: AppTheme.outlineVariant),
                ],
              );
            }).toList(),
          );
        }
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
    required this.statusLabel,
  });

  final String title;
  final String date;
  final String amount;
  final bool isPositive;
  final ChipStatus status;
  final String statusLabel;

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
                label: statusLabel[0].toUpperCase() + statusLabel.substring(1),
                status: status,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
